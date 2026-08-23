import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/repositories/job_card_repository.dart';
import 'technician_provider.dart';
import '../profile/user_provider.dart';
import 'widgets/service_team_alert_monitor.dart';
import 'widgets/pre_arrival_video_diagnostic_modal.dart';
import '../driver/widgets/instant_cashout_sheet.dart';
import '../../core/services/tracking_service.dart';
import '../../core/services/language_service.dart';

// Technician online/offline availability toggle — persists within session.
final techOnlineProvider = StateProvider<bool>((ref) => true);

class TechnicianDashboardScreen extends ConsumerStatefulWidget {
  const TechnicianDashboardScreen({super.key});

  @override
  ConsumerState<TechnicianDashboardScreen> createState() =>
      _TechnicianDashboardScreenState();
}

class _TechnicianDashboardScreenState
    extends ConsumerState<TechnicianDashboardScreen> {
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final techId = ref.read(userProvider).user?.id ?? 'demo';
      ref.read(trackingServiceProvider).startTracking(techId);
    });
  }

  // — Nav handler —
  void _onBottomNavTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _bottomNavIndex = index);
    switch (index) {
      case 0:
        break; // Already on dashboard
      case 1:
        context.go('/tech-tasks');
        break;
      case 2:
        context.go('/tech-spare-parts');
        break;
      case 3:
        context.go('/tech-profile');
        break;
    }
  }

  // — Pull-to-refresh —
  Future<void> _refreshDashboard() async {
    // ignore: unawaited_futures
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Dashboard refreshed!'),
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xFF1A237E)),
      );
    }
  }

  // — Add Vehicle Modal —
  void _showAddVehicleSheet() {
    final formKey = GlobalKey<FormState>();
    final modelCtrl = TextEditingController();
    final regNoCtrl = TextEditingController();
    final colorCtrl = TextEditingController();
    final ownerCtrl = TextEditingController();
    final mileageCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: const Color(0xFFE5E9F0),
                        borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Icon(Icons.directions_car_filled_rounded,
                        color: Color(0xFF1A237E), size: 22),
                    SizedBox(width: 12),
                    Text('Add New Vehicle',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A237E))),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Enter vehicle details to create a new job card.',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 28),
                _buildFormField(
                    modelCtrl,
                    'Vehicle Model',
                    'e.g. 2021 Toyota Rav4',
                    Icons.directions_car_filled_rounded,
                    true),
                const SizedBox(height: 16),
                _buildFormField(regNoCtrl, 'Registration No.',
                    'e.g. MH 12 AB 1234', Icons.description_rounded, true),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _buildFormField(colorCtrl, 'Color', 'e.g. White',
                            Icons.palette_rounded, false)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildFormField(mileageCtrl, 'Mileage (km)',
                            'e.g. 45000', Icons.speed_rounded, false,
                            isNumber: true)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFormField(ownerCtrl, 'Owner Name', 'e.g. Rajesh Kumar',
                    Icons.person_rounded, false),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        // ignore: unawaited_futures
                        HapticFeedback.heavyImpact();
                        try {
                          await ref
                              .read(jobCardRepositoryProvider)
                              .createJobCard(
                                techId: 'self', // Technician ID
                                vehicleMake: 'Unknown',
                                vehicleModel: modelCtrl.text,
                                regNo: regNoCtrl.text,
                                notes: 'Dashboard Job',
                              );

                          // Create a new job with the vehicle info
                          final newJob = TechnicianJob(
                            id: 'JOB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                            estimatedCompletion: DateFormat('hh:mm a').format(
                                DateTime.now().add(const Duration(hours: 3))),
                            vehicleModel: modelCtrl.text,
                            vehiclePlate: regNoCtrl.text,
                            progress: 0.0,
                            checklist: [
                              ChecklistItem(
                                  task: 'Pre-service Inspection',
                                  category: 'Initial'),
                              ChecklistItem(
                                  task: 'Engine Diagnosis',
                                  category: 'Core Service'),
                              ChecklistItem(
                                  task: 'Wait for Customer Approval',
                                  category: 'Communication'),
                              ChecklistItem(
                                  task: 'Final Quality Check',
                                  category: 'Quality'),
                            ],
                            parts: [],
                            status: 'ACCEPTED',
                          );
                          ref
                              .read(technicianProvider.notifier)
                              .createJob(newJob);
                          ref.read(selectedJobIdProvider.notifier).state =
                              newJob.id;
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Vehicle "${modelCtrl.text}" added & job created!'),
                                backgroundColor: const Color(0xFF28C76F)),
                          );
                          // ignore: unawaited_futures
                          context.push('/tech-job-card');
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to create job: $e'),
                                backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('Create Vehicle Job',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(TextEditingController ctrl, String label, String hint,
      IconData icon, bool required,
      {bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
          : null,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A237E)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(
            color: Colors.grey, fontSize: 13, fontWeight: FontWeight.normal),
        labelStyle: const TextStyle(
            color: Color(0xFF1A237E),
            fontSize: 13,
            fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon, color: const Color(0xFF5E6AD2), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E9F0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E9F0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final jobs = ref.watch(technicianProvider);
    final activeJob = ref.watch(selectedJobProvider);
    final l10n = ref.watch(l10nProvider);

    final pendingJobs = jobs.where((j) => j.status != 'COMPLETED').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshDashboard,
          color: const Color(0xFF1A237E),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const ServiceTeamAlertMonitor(),
                // ─── 1. Header ───
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${l10n.greeting} ${user.user?.name.split(' ')[0] ?? 'Technician'}',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A237E))),
                        const SizedBox(height: 4),
                        // Online / Offline availability toggle
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            final isOnline = ref.read(techOnlineProvider);
                            ref.read(techOnlineProvider.notifier).state =
                                !isOnline;
                          },
                          child: Consumer(
                            builder: (_, ref, __) {
                              final isOnline = ref.watch(techOnlineProvider);
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isOnline
                                      ? const Color(0xFF28C76F)
                                          .withValues(alpha: 0.12)
                                      : Colors.grey.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isOnline
                                        ? const Color(0xFF28C76F)
                                            .withValues(alpha: 0.4)
                                        : Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: isOnline
                                            ? const Color(0xFF28C76F)
                                            : Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isOnline ? 'Online' : 'Offline',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isOnline
                                            ? const Color(0xFF28C76F)
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push('/tech-qr-scanner');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10)
                              ],
                            ),
                            child: const Icon(Icons.qr_code_scanner_rounded,
                                color: Color(0xFF1A237E), size: 22),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push('/notifications');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10)
                              ],
                            ),
                            child: Stack(
                              children: [
                                const Icon(Icons.notifications_none_rounded,
                                    color: Color(0xFF1A237E), size: 22),
                                Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ).animate().fadeIn().slideX(begin: -0.1, end: 0),

                const SizedBox(height: 24),

                // ─── 2. Weekly Performance Card ───
                _buildMainPerformanceCard(jobs),

                const SizedBox(height: 16),

                // ─── 2b. Today's Earnings Row ───
                _buildTodayEarningsRow(jobs),

                const SizedBox(height: 24),

                // ─── 3. Quick Actions ───
                const Text('Quick Actions',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A237E))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _buildActionCard(
                            'Add Vehicle',
                            Icons.add_box_rounded,
                            const Color(0xFF5E6AD2),
                            _showAddVehicleSheet)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildActionCard(
                            'Inventory',
                            Icons.inventory_2_rounded,
                            const Color(0xFFFF9F43),
                            () => context.push('/tech-spare-parts'))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildActionCard(
                            'All Jobs',
                            Icons.bar_chart_rounded,
                            const Color(0xFF28C76F),
                            () => context.push('/tech-tasks'))),
                  ],
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 32),

                // ─── 4. Active Vehicle Context (Editable) ───
                if (activeJob != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Current Vehicle',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A237E))),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.push('/tech-job-card');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: const Color(0xFFE8EAF6),
                              borderRadius: BorderRadius.circular(20)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_rounded,
                                  size: 14, color: Color(0xFF1A237E)),
                              SizedBox(width: 6),
                              Text('Edit Details',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A237E))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildVehicleContextCard(activeJob),
                  const SizedBox(height: 32),
                ],

                // ─── 5. Active Tasks ───
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Active Tasks',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A237E))),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.push('/tech-tasks');
                      },
                      child: const Text('View All',
                          style: TextStyle(
                              color: Color(0xFF5E6AD2),
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (pendingJobs.isEmpty)
                  const Center(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No active tasks'))),
                ...pendingJobs
                    .take(3)
                    .map((job) => _buildTaskPreviewItem(context, job)),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.push('/tech-create-job');
        },
        backgroundColor: const Color(0xFF1A237E),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Create Job Card',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ─── Vehicle Context Card ───
  Widget _buildVehicleContextCard(TechnicianJob job) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/tech-job-card');
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF3949AB)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF1A237E).withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                      color: Colors.white24, shape: BoxShape.circle),
                  child: const Icon(Icons.directions_car_filled_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.vehicleModel,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6)),
                            child: Text(job.vehiclePlate,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70)),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (job.status == 'COMPLETED'
                                      ? Colors.greenAccent
                                      : Colors.amberAccent)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              job.status,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: job.status == 'COMPLETED'
                                      ? Colors.greenAccent
                                      : Colors.amberAccent),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white54, size: 16),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 12),
            // Field Partner Quick Actions: Video Diag, GPS Nav, Log Parts, Sign-off
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      PreArrivalVideoDiagnosticModal.show(
                        context,
                        vehicleModel: job.vehicleModel,
                        vehiclePlate: job.vehiclePlate,
                      );
                    },
                    icon: const Icon(Icons.videocam_rounded,
                        size: 14, color: Colors.white),
                    label: const Text('Video Diag',
                        style: TextStyle(color: Colors.white, fontSize: 10)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Launching GPS Navigation to ${job.vehiclePlate}...'),
                          backgroundColor: const Color(0xFF1A237E),
                        ),
                      );
                    },
                    icon: const Icon(Icons.navigation_rounded,
                        size: 14, color: Colors.white),
                    label: const Text('GPS Nav',
                        style: TextStyle(color: Colors.white, fontSize: 10)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showPartsLoggerModal(context, job);
                    },
                    icon: const Icon(Icons.handyman_rounded,
                        size: 14, color: Colors.white),
                    label: const Text('Log Parts',
                        style: TextStyle(color: Colors.white, fontSize: 10)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _showCustomerSignoffModal(context, job);
                    },
                    icon: const Icon(Icons.draw_rounded,
                        size: 14, color: Color(0xFF1A237E)),
                    label: const Text('Sign-off',
                        style: TextStyle(
                            color: Color(0xFF1A237E),
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.08, end: 0);
  }

  void _showPartsLoggerModal(BuildContext context, TechnicianJob job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Text('Log Spare Parts • ${job.vehiclePlate}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E))),
            const SizedBox(height: 14),
            TextField(
              decoration: InputDecoration(
                labelText: 'Part Name / Part Number',
                hintText: 'e.g. Bosch Brake Pad Set (Front)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Qty',
                      hintText: '1',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price (₹)',
                      hintText: '1450',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Spare parts logged to job invoice.'),
                        backgroundColor: Color(0xFF28C76F)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add to Job Card',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerSignoffModal(BuildContext context, TechnicianJob job) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.draw_rounded, color: Color(0xFF1A237E)),
            SizedBox(width: 10),
            Text('Customer Digital Sign-Off',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehicle: ${job.vehicleModel} (${job.vehiclePlate})',
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text(
                'Please hand phone to customer to draw signature confirming job completion.',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(
                child: Text('✍️ Customer Signature Area',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Customer signature captured & verified!'),
                    backgroundColor: Color(0xFF28C76F)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF28C76F),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirm Sign-off',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─── Performance Card ───
  Widget _buildMainPerformanceCard(List<TechnicianJob> jobs) {
    final completedCount = jobs.where((j) => j.status == 'COMPLETED').length;
    final totalJobs = jobs.length;
    final pendingCount = totalJobs - completedCount;
    final now = DateTime.now();

    // Per-weekday job fractions (Mon=0 … Sun=6)
    // Mark today's index with the real completed count; other days get 0.
    final dayCounts = List.filled(7, 0);
    dayCounts[now.weekday - 1] = completedCount;
    final maxCount = dayCounts.reduce((a, b) => a > b ? a : b).clamp(1, 9999);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A237E), Color(0xFF3949AB)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1A237E).withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('THIS WEEK',
                      style: TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text('$completedCount Jobs Done · $pendingCount Pending',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900)),
                ],
              ),
              if (totalJobs > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up_rounded,
                          color: Colors.greenAccent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                          '${((completedCount / totalJobs) * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildChartBar('Mon', dayCounts[0] / maxCount),
              _buildChartBar('Tue', dayCounts[1] / maxCount),
              _buildChartBar('Wed', dayCounts[2] / maxCount),
              _buildChartBar('Thu', dayCounts[3] / maxCount),
              _buildChartBar('Fri', dayCounts[4] / maxCount),
              _buildChartBar('Sat', dayCounts[5] / maxCount),
              _buildChartBar('Sun', dayCounts[6] / maxCount,
                  isToday: now.weekday == 7),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  // ─── Today's Earnings Row ───
  Widget _buildTodayEarningsRow(List<TechnicianJob> jobs) {
    // Sum prices of all completed jobs (parse ₹ prefix)
    double total = 0;
    double todayTotal = 0;
    final today = DateFormat('dd MMM').format(DateTime.now());
    for (final job in jobs) {
      double amt = 0;
      try {
        amt = double.parse(job.price.replaceAll(RegExp(r'[^\d.]'), ''));
      } catch (_) {}
      total += amt;
      if (job.date == today || job.date == 'Today') todayTotal += amt;
    }

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        InstantCashoutSheet.show(
          context,
          availableBalance: total > 0 ? total : 3200.0,
          defaultUpiId: 'technician.partner@oksbi',
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E9F0)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF28C76F).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  color: Color(0xFF28C76F), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Today\'s Earnings',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B))),
                  const SizedBox(height: 2),
                  Text(
                    todayTotal > 0
                        ? '₹${todayTotal.toStringAsFixed(0)}'
                        : 'No completed jobs yet',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A237E)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Cash Out',
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF28C76F),
                        fontWeight: FontWeight.bold)),
                Text(
                  '₹${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF28C76F)),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildChartBar(String day, double percent, {bool isToday = false}) {
    final clampedPercent = percent.clamp(0.05, 1.0);
    return Column(
      children: [
        Container(
          width: 25,
          height: 80 * clampedPercent,
          decoration: BoxDecoration(
            color: isToday
                ? Colors.greenAccent
                : Colors.white
                    .withValues(alpha: clampedPercent > 0.6 ? 1.0 : 0.4),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(day,
            style: TextStyle(
                color: isToday ? Colors.greenAccent : Colors.white60,
                fontSize: 10,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  // ─── Quick Action Card ───
  Widget _buildActionCard(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E9F0)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E))),
          ],
        ),
      ),
    );
  }

  // ─── Task Preview Item ───
  Widget _buildTaskPreviewItem(BuildContext context, TechnicianJob job) {
    final status = job.status == 'COMPLETED'
        ? 'Done'
        : (job.status == 'IN PROGRESS'
            ? 'In-Progress'
            : (job.status == 'ACCEPTED' ? 'Priority' : 'To-Do'));
    final statusColor = status == 'Done'
        ? const Color(0xFF28C76F)
        : (status == 'In-Progress'
            ? const Color(0xFF5E6AD2)
            : const Color(0xFFFF9F43));
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(selectedJobIdProvider.notifier).state = job.id;
        context.push('/tech-job-card-details');
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E9F0)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.directions_car_rounded, color: statusColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.vehicleModel,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: Color(0xFF1A237E))),
                  Text('${job.vehiclePlate} • ${job.estimatedCompletion}',
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(status,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 50.ms).slideX(begin: 0.05, end: 0);
  }

  // ─── Bottom Navigation ───
  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F2F4))),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, 'Dashboard', 0),
          _navItem(Icons.task_alt_rounded, 'Jobs', 1),
          _navItem(Icons.inventory_2_rounded, 'Parts', 2),
          _navItem(Icons.person_rounded, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isActive = _bottomNavIndex == index;
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFE8EAF6) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: isActive ? const Color(0xFF1A237E) : Colors.grey,
                  size: 24),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? const Color(0xFF1A237E) : Colors.grey)),
          ],
        ),
      ),
    );
  }
}
