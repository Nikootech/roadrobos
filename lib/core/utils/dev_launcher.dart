import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../config/app_config.dart';
import '../../features/profile/user_provider.dart';
import '../services/auth_service.dart';
import 'app_debugger.dart';


/// ── DEV LAUNCHER OVERLAY ────────────────────────────────────────────────────
/// A draggable floating button visible ONLY in debug/dev mode.
/// Lets developers jump to any screen instantly without logging in.
///
/// Usage — wrap your MaterialApp child with DevLauncher:
///   DevLauncher(child: MyApp())
///
/// Or add it as an Overlay inside a Navigator via DevLauncher.maybeWrap().
/// ────────────────────────────────────────────────────────────────────────────

class DevLauncher extends StatefulWidget {
  final Widget child;

  const DevLauncher({super.key, required this.child});

  /// Wrap [child] with DevLauncher only when debug features are enabled.
  /// Returns [child] unchanged in production.
  static Widget maybeWrap({required Widget child}) {
    if (!kDebugMode || !AppConfig.showDebugFeatures) return child;
    return DevLauncher(child: child);
  }

  @override
  State<DevLauncher> createState() => _DevLauncherState();
}

class _DevLauncherState extends State<DevLauncher>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  double _dy = 200; // vertical offset of the FAB
  late AnimationController _animCtrl;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slideAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    _isOpen ? _animCtrl.forward() : _animCtrl.reverse();
  }

  void _navigateTo(BuildContext ctx, String route) {
    _toggle(); // close panel
    // Small delay so panel closes before navigation
    Future.delayed(const Duration(milliseconds: 150), () {
      if (ctx.mounted) ctx.go(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // ── Backdrop (tap to close) ──────────────────────────────────────────
        if (_isOpen)
          GestureDetector(
            onTap: _toggle,
            child: Container(color: Colors.black.withValues(alpha: 0.45)),
          ),

        // ── Slide-in Panel ───────────────────────────────────────────────────
        AnimatedBuilder(
          animation: _slideAnim,
          builder: (_, __) => Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 260,
            child: Transform.translate(
              offset: Offset(260 * (1 - _slideAnim.value), 0),
              child: _DevPanel(onNavigate: (r) => _navigateTo(context, r)),
            ),
          ),
        ),

        // ── Draggable FAB ────────────────────────────────────────────────────
        Positioned(
          right: _isOpen ? 272 : 0,
          top: _dy,
          child: GestureDetector(
            onVerticalDragUpdate: (d) {
              setState(() {
                _dy = (_dy + d.delta.dy).clamp(
                  60,
                  MediaQuery.of(context).size.height - 100,
                );
              });
            },
            child: GestureDetector(
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isOpen ? 42 : 36,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                  border: Border.all(
                    color: const Color(0xFF00FF88).withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FF88).withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bug_report_rounded,
                        color: Color(0xFF00FF88), size: 18),
                    const SizedBox(height: 2),
                    RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        'DEV',
                        style: TextStyle(
                          color: const Color(0xFF00FF88).withValues(alpha: 0.8),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Panel Content ─────────────────────────────────────────────────────────────
class _DevPanel extends ConsumerStatefulWidget {
  final void Function(String route) onNavigate;

  const _DevPanel({required this.onNavigate});

  @override
  ConsumerState<_DevPanel> createState() => _DevPanelState();
}

class _DevPanelState extends ConsumerState<_DevPanel> {
  int _activeTab = 0; // 0 = Screens, 1 = Diagnostics, 2 = Logs

  static const _sections = [
    _Section('🔐 Auth', [
      _Item('Onboarding', '/onboarding', Icons.swipe_rounded),
      _Item('Role Selection', '/auth/role-selection', Icons.people_rounded),
      _Item('Login', '/auth/login', Icons.login_rounded),
      _Item('Register', '/auth/register', Icons.person_add_rounded),
      _Item('Login Callback', '/login-callback', Icons.link_rounded),
    ]),
    _Section('👤 Customer', [
      _Item('Home', '/main/home', Icons.home_rounded),
      _Item('Bookings', '/main/bookings', Icons.calendar_month_rounded),
      _Item('Explore', '/main/explore', Icons.explore_rounded),
      _Item('Profile', '/main/profile', Icons.person_rounded),
      _Item('Wallet', '/wallet', Icons.account_balance_wallet_rounded),
      _Item('Ride Booking', '/book-ride', Icons.directions_car_rounded),
      _Item('Notifications', '/notifications', Icons.notifications_rounded),
      _Item('Chat', '/chat', Icons.chat_rounded),
      _Item('Loyalty', '/loyalty', Icons.stars_rounded),
    ]),
    _Section('🚗 Driver', [
      _Item('Driver Home', '/driver-home', Icons.local_taxi_rounded),
      _Item('Driver Rides', '/driver-rides', Icons.route_rounded),
      _Item('Driver Earnings', '/driver-earnings', Icons.attach_money_rounded),
      _Item('Driver KYC', '/driver/kyc-upload', Icons.verified_user_rounded),
    ]),
    _Section('🔧 Technician', [
      _Item('Tech Dashboard', '/tech-dashboard', Icons.build_rounded),
      _Item('Tech Tasks', '/tech-tasks', Icons.checklist_rounded),
      _Item('Tech Earnings', '/tech-earnings', Icons.payments_rounded),
    ]),
    _Section('👑 Admin', [
      _Item('Admin Home', '/admin-home', Icons.admin_panel_settings_rounded),
      _Item('Admin Revenue', '/admin-revenue', Icons.bar_chart_rounded),
      _Item('Admin KYC', '/admin-kyc', Icons.fact_check_rounded),
      _Item('Manage Offers', '/admin-manage-offers', Icons.local_offer_rounded),
      _Item('Audit Logs', '/admin/audit-logs', Icons.history_rounded),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0D1117),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 12,
              12,
              12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF00FF88).withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.bug_report_rounded,
                    color: Color(0xFF00FF88), size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'DEV LAUNCHER',
                    style: TextStyle(
                      color: Color(0xFF00FF88),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF88).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: const Color(0xFF00FF88).withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    'DEV',
                    style: TextStyle(
                      color: Color(0xFF00FF88),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: const Color(0xFF161B22),
            child: Row(
              children: [
                _buildTabButton(0, 'SCREENS', Icons.layers_rounded),
                _buildTabButton(1, 'DIAGS', Icons.analytics_rounded),
                _buildTabButton(2, 'LOGS', Icons.article_rounded),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: _buildActiveTabContent(),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            child: Text(
              '🔒 Visible only in debug mode\nENV: ${AppConfig.isDev ? "dev" : AppConfig.isProd ? "prod" : "staging"}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 10,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final active = _activeTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? const Color(0xFF00FF88) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: active ? const Color(0xFF00FF88) : Colors.white.withValues(alpha: 0.4),
                size: 15,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: active ? const Color(0xFF00FF88) : Colors.white.withValues(alpha: 0.4),
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_activeTab) {
      case 0:
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: _sections
              .map((s) => _SectionWidget(section: s, onTap: widget.onNavigate))
              .toList(),
        );
      case 1:
        return _buildDiagnosticsView();
      case 2:
        return _buildLogsView();
      default:
        return const SizedBox();
    }
  }

  Widget _buildDiagnosticsView() {
    UserState? userState;
    AsyncValue<sb.User?>? authState;
    try {
      userState = ref.watch(userProvider);
      authState = ref.watch(authNotifierProvider);
    } catch (_) {}

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('STARTUP STATUS'),
        if (AppDebugger.startupSteps.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No startup logs tracked.',
              style: TextStyle(fontSize: 12, color: Colors.white38),
            ),
          ),
        ...AppDebugger.startupSteps.entries.map((entry) {
          final isSuccess = entry.value == 'SUCCESS';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSuccess ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSuccess ? Colors.green.withValues(alpha: 0.5) : Colors.red.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isSuccess ? Colors.greenAccent : Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
        
        _buildSectionHeader('ENVIRONMENT CONFIG'),
        _buildConfigItem('SUPABASE_URL', AppConfig.supabaseUrl.isNotEmpty ? 'SET' : 'EMPTY', isCritical: true),
        _buildConfigItem('SUPABASE_ANON_KEY', AppConfig.supabaseAnonKey.isNotEmpty ? 'SET' : 'EMPTY', isCritical: true),
        _buildConfigItem('GOOGLE_CLIENT_ID', AppConfig.googleClientId.isNotEmpty ? 'SET' : 'EMPTY'),
        _buildConfigItem('RAZORPAY_KEY_ID', AppConfig.razorpayKey.isNotEmpty ? 'SET' : 'EMPTY'),
        _buildConfigItem('SENTRY_DSN', AppConfig.sentryDsn.isNotEmpty ? 'SET' : 'EMPTY'),
        const SizedBox(height: 20),

        _buildSectionHeader('REAL-TIME AUTH STATE'),
        _buildStateItem('Auth Loading', authState?.isLoading.toString() ?? 'N/A'),
        _buildStateItem('Logged In', (authState?.value != null || (userState?.isDemo ?? false)).toString()),
        _buildStateItem('User UID', authState?.value?.id.substring(0, 8) ?? (userState?.isDemo == true ? 'demo_user' : 'null')),
        _buildStateItem('User Name', userState?.name ?? 'null'),
        _buildStateItem('User Role', userState?.user?.role.name ?? 'null'),
        _buildStateItem('Is Approved', userState?.user?.isApproved.toString() ?? 'null'),
      ],
    );
  }

  Widget _buildLogsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => setState(() {}),
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: const Text('Refresh', style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF00FF88)),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    AppDebugger.debugLogs.clear();
                  });
                },
                icon: const Icon(Icons.delete_sweep_rounded, size: 14),
                label: const Text('Clear', style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(foregroundColor: Colors.white54),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10),
            ),
            child: AppDebugger.debugLogs.isEmpty
                ? const Center(
                    child: Text(
                      'No logs yet.',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  )
                : ListView.builder(
                    itemCount: AppDebugger.debugLogs.length,
                    itemBuilder: (context, index) {
                      final log = AppDebugger.debugLogs[index];
                      final isError = log.contains('failed') || log.contains('Error') || log.contains('Exception') || log.contains('FAILED');
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          log,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: isError ? const Color(0xFFFF4E4E) : Colors.white70,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00FF88),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          const Divider(color: Colors.white12, height: 1),
        ],
      ),
    );
  }

  Widget _buildConfigItem(String key, String value, {bool isCritical = false}) {
    final isEmpty = value == 'EMPTY';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: const TextStyle(fontSize: 11, color: Colors.white60)),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isEmpty
                  ? (isCritical ? const Color(0xFFFF4E4E) : Colors.amber)
                  : const Color(0xFF00FF88),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white60)),
          Text(
            value,
            style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  final _Section section;
  final void Function(String) onTap;

  const _SectionWidget({required this.section, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Text(
            section.label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
        ...section.items.map(
          (item) => InkWell(
            onTap: () => onTap(item.route),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Row(
                children: [
                  Icon(item.icon,
                      color: Colors.white.withValues(alpha: 0.5), size: 15),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withValues(alpha: 0.2), size: 10),
                ],
              ),
            ),
          ),
        ),
        Divider(
          color: Colors.white.withValues(alpha: 0.05),
          height: 1,
          indent: 12,
        ),
      ],
    );
  }
}

class _Section {
  final String label;
  final List<_Item> items;
  const _Section(this.label, this.items);
}

class _Item {
  final String label;
  final String route;
  final IconData icon;
  const _Item(this.label, this.route, this.icon);
}
