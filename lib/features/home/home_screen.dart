import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/widgets/responsive_utils.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/app_avatar.dart';
import 'vehicle_provider.dart';
import '../profile/user_provider.dart';
import '../rentals/rental_providers.dart';
import '../technician/technician_provider.dart';
import '../../core/repositories/wallet_repository.dart';
import '../../core/services/language_service.dart';
import '../../core/models/user_role.dart';
import '../../core/providers/rbac_provider.dart';
import 'home_providers.dart';
import '../../core/repositories/quick_action_repository.dart';
import '../../core/utils/icon_helper.dart';
import '../../core/models/service_booking.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {




  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).user;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: () async {
          // Targeted refresh: Only re-fetch data providers, not the full user state tree
          ref.invalidate(recentServiceBookingsProvider);
          ref.invalidate(homeCategoriesProvider);
          ref.invalidate(quickActionsProvider);
          ref.invalidate(homeOffersProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(ref)),
            SliverToBoxAdapter(child: _buildGreetingSection(ref)),
            SliverToBoxAdapter(child: _buildWalletBalanceCard(ref)),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildLiveStatusCard(ref)),
            SliverToBoxAdapter(child: _buildQuickActions()),
            SliverToBoxAdapter(child: _buildRecentServices(ref)),
            SliverToBoxAdapter(child: _buildExploreGrid()),
            SliverToBoxAdapter(child: _buildOffersCarousel()),
            SliverToBoxAdapter(
              child: Padding(
                padding: ResponsiveLayout.responsivePadding(context, horizontal: 20, vertical: 20).copyWith(bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('More Services', style: GoogleFonts.outfit(fontSize: ResponsiveLayout.responsiveFontSize(context, 20), fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildMoreTile(context, 'Add Vehicle', Icons.add_circle_outline_rounded, const Color(0xFF3B82F6), '/add-vehicle'),
                        _buildMoreTile(context, 'Loyalty', Icons.card_membership_rounded, const Color(0xFFF97316), '/loyalty'),
                        _buildMoreTile(context, 'Help', Iconsax.message_question, const Color(0xFF8B5CF6), '/help-center'),
                        _buildMoreTile(context, 'History', Icons.history_rounded, const Color(0xFFF97316), '/ride-history'),
                        _buildMoreTile(context, 'Referral', Icons.card_giftcard_rounded, const Color(0xFFEC4899), '/referral'),
                        _buildMoreTile(context, 'Emergency', Iconsax.shield_slash, AppColors.dangerRed, '/sos-setup'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (user != null && (ref.watch(hasPermissionProvider('admin_access')) || ref.watch(hasPermissionProvider('field_staff_access'))))
              SliverToBoxAdapter(
                child: Padding(
                  padding: ResponsiveLayout.responsivePadding(context, horizontal: 20, vertical: 24).copyWith(bottom: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Switch View', style: GoogleFonts.outfit(fontSize: ResponsiveLayout.responsiveFontSize(context, 20), fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          if (ref.watch(hasPermissionProvider('admin_access')) || user.role == UserRole.driver)
                            _buildRoleCard(context, 'Driver', Icons.local_taxi_rounded, const Color(0xFF22C55E), '/driver-home'),
                          if (ref.watch(hasPermissionProvider('admin_access')) || user.role == UserRole.technician)
                            _buildRoleCard(context, 'Technician', Icons.build_rounded, const Color(0xFFF97316), '/tech-tasks'),
                          if (ref.watch(hasPermissionProvider('admin_access')))
                            _buildRoleCard(context, 'Admin', Icons.shield_rounded, const Color(0xFF6366F1), '/admin-home'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    // P1: .select() — only rebuilds when profileImageUrl changes, not on any UserState field change
    final imageUrl = ref.watch(userProvider.select((s) => s.profileImageUrl));
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: ResponsiveLayout.responsivePadding(context, horizontal: 20, vertical: 16).copyWith(bottom: 0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.push('/main/profile'),
              child: AppAvatar(
                imageUrl: imageUrl,
                radius: 22,
                backgroundColor: Colors.white,
              ),
            ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
            const Spacer(),
            // Trailing Icons Row - Constrained to prevent overflow
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Language Selection Menu
                PopupMenuButton<AppLanguage>(
                  onSelected: (AppLanguage lang) {
                    ref.read(languageProvider.notifier).setLanguage(lang);
                  },
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: AppLanguage.en, child: Text('English (EN)')),
                    const PopupMenuItem(value: AppLanguage.hi, child: Text('हिन्दी (HI)')),
                    const PopupMenuItem(value: AppLanguage.kn, child: Text('ಕನ್ನಡ (KN)')),
                    const PopupMenuItem(value: AppLanguage.ta, child: Text('தமிழ் (TA)')),
                    const PopupMenuItem(value: AppLanguage.te, child: Text('తెలుగు (TE)')),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      ref.watch(languageProvider).name.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push('/notifications');
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Iconsax.notification, size: 20, color: AppColors.textPrimary),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(color: AppColors.dangerRed, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 100.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildGreetingSection(WidgetRef ref) {
    // P1: .select() — only rebuilds when user name changes
    final userName = ref.watch(userProvider.select((s) => s.name));
    final selectedVehicle = ref.watch(vehicleProvider);
    final allVehicles = ref.watch(allVehiclesProvider);
    final l10n = ref.watch(l10nProvider);

    return Padding(
      padding: ResponsiveLayout.responsivePadding(context, horizontal: 20, vertical: 20).copyWith(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.get('good_morning'), style: TextStyle(fontSize: ResponsiveLayout.responsiveFontSize(context, 14), color: AppColors.textSecondary)).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 4),
          Text(userName.split(' ')[0], style: TextStyle(fontSize: ResponsiveLayout.responsiveFontSize(context, 28), fontWeight: FontWeight.w800, color: AppColors.textPrimary)).animate(delay: 100.ms).fadeIn(duration: 500.ms).slideX(begin: -0.05, end: 0),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  padding: EdgeInsets.only(
                    left: 24, right: 24, top: 12,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 24),
                      Text('Select Vehicle', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: allVehicles.length,
                          itemBuilder: (context, index) {
                            final vehicle = allVehicles[index];
                            return ListTile(
                              onTap: () {
                                ref.read(vehicleProvider.notifier).setVehicle(vehicle);
                                Navigator.pop(context);
                              },
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: AppColors.bgSkyLight, borderRadius: BorderRadius.circular(10)),
                                child: Icon(
                                  vehicle.type == 'Car' ? Icons.directions_car_rounded : (vehicle.type == 'EV Bike' ? Icons.electric_bike_rounded : Icons.pedal_bike_rounded), 
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              title: Text(vehicle.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(vehicle.plate),
                              trailing: selectedVehicle.plate == vehicle.plate ? const Icon(Icons.check_circle_rounded, color: AppColors.successGreen) : null,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          context.push('/add-vehicle');
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        label: const Text('Add New Vehicle'),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.bgSkyLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1))),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(selectedVehicle.name.toLowerCase().contains('car') ? Icons.directions_car_rounded : Icons.pedal_bike_rounded, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(AppStrings.selectedVehicle, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
                        const SizedBox(height: 2),
                        Text('${selectedVehicle.name}  •  ${selectedVehicle.plate}', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                    child: const Text(AppStrings.change, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryBlue)),
                  ),
                ],
              ),
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildWalletBalanceCard(WidgetRef ref) {
    final user = ref.watch(userProvider.select((s) => s.user));
    final userId = user?.id;
    final walletAsync = userId != null && !userId.startsWith('demo') 
        ? ref.watch(walletStreamProvider(userId))
        : const AsyncValue.loading();
    final l10n = ref.watch(l10nProvider);

    return Padding(
      padding: ResponsiveLayout.responsivePadding(context, horizontal: 20, vertical: 16).copyWith(bottom: 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primaryBlue, AppColors.primaryBlueDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.get('wallet_balance'), style: TextStyle(fontSize: ResponsiveLayout.responsiveFontSize(context, 12), color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: walletAsync.when(
                      data: (wallet) => Text('₹ ${(wallet?.balance ?? 0.0).toStringAsFixed(2)}', style: TextStyle(fontSize: ResponsiveLayout.responsiveFontSize(context, 24), fontWeight: FontWeight.w700, color: Colors.white)),
                      loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                      error: (_, __) => const Text('₹ --', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatItem('Points', ref.watch(userProvider.select((s) => s.points)).toString(), Icons.stars_rounded),
                      const SizedBox(width: 16),
                      _buildStatItem('Rides', ref.watch(userProvider.select((s) => s.totalRides)).toString(), Icons.directions_car_rounded),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12), // Minimum spacing
            // Top-Up Button - Constrained
            Flexible(
              flex: 0,
              child: GestureDetector(
                onTap: () => context.push('/wallet'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_circle_outline_rounded, size: 18, color: Colors.white), 
                      const SizedBox(width: 8), 
                      Flexible(
                        child: Text(
                          l10n.get('top_up'), 
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: 250.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: ResponsiveLayout.responsivePadding(context, horizontal: 20, vertical: 16).copyWith(bottom: 0),
      child: GestureDetector(
        onTap: () => context.push('/main/explore'),
        child: Container(
          height: 48,
          decoration: BoxDecoration(color: AppColors.bgSkyLight, borderRadius: BorderRadius.circular(14)),
          child: const Row(children: [SizedBox(width: 16), Icon(Iconsax.search_normal, size: 18, color: AppColors.textMuted), SizedBox(width: 12), Text(AppStrings.searchServices, style: TextStyle(fontSize: 14, color: AppColors.textMuted))]),
        ),
      ),
    ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildLiveStatusCard(WidgetRef ref) {
    final activeRental = ref.watch(activeRentalProvider);
    final TechnicianJob? activeJob = ref.watch(selectedJobProvider);
    if (activeRental == null && activeJob == null) return const SizedBox.shrink();
    final isRental = activeRental != null;
    final title = isRental ? activeRental.vehicle['name'] : '${activeJob!.serviceType} - ${activeJob.packageName}';
    final subtitle = isRental ? activeRental.status.name.toUpperCase() : '${activeJob!.vehicleModel} (${activeJob.vehiclePlate})';
    final statusColor = isRental ? (activeRental.status == RentalStatus.active ? AppColors.successGreen : AppColors.accentOrange) : AppColors.primaryBlue;
    return Padding(
      padding: ResponsiveLayout.responsivePadding(context, horizontal: 20, vertical: 16).copyWith(bottom: 0),
      child: GlassCard(
        onTap: () => context.push(isRental ? '/delivery-logistics' : '/live-service-status'),
        borderRadius: 32,
        opacity: 0.08,
        blur: 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)), const SizedBox(width: 8), Text(isRental ? 'Active Rental' : 'Service in Progress', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: statusColor))]),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: activeJob?.progress ?? 0.65, backgroundColor: AppColors.bgSkyLight, valueColor: AlwaysStoppedAnimation(statusColor), minHeight: 6)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    ).animate(delay: 350.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actionsAsync = ref.watch(quickActionsProvider);

    return Padding(
      padding: ResponsiveLayout.responsivePadding(context, horizontal: 20, vertical: 24).copyWith(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ref.watch(l10nProvider).get('quick_actions'), style: TextStyle(fontSize: ResponsiveLayout.responsiveFontSize(context, 18), fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          actionsAsync.when(
            data: (actions) {
              if (actions.isEmpty) return const SizedBox.shrink();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: actions.map((action) => _buildQuickActionItem(action)).toList(),
              );
            },
            loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
            error: (err, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn();
  }

  Widget _buildQuickActionItem(QuickAction action) {
    final color = IconHelper.getColor(action.color);
    return GestureDetector(
      onTap: () => context.push(action.route),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(IconHelper.getIcon(action.icon), color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(action.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildRecentServices(WidgetRef ref) {
    final bookingsAsync = ref.watch(recentServiceBookingsProvider);

    return bookingsAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: ResponsiveLayout.responsivePadding(context, horizontal: 20, vertical: 24).copyWith(bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recent Services', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ...bookings.take(2).map((booking) => _buildRecentServiceCard(booking)),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    ).animate(delay: 500.ms).fadeIn();
  }

  Widget _buildRecentServiceCard(ServiceBooking booking) {
    return GestureDetector(
      onTap: () => context.push('/live-service-status'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgSkyLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.build_rounded, color: AppColors.primaryBlue, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.packageName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('${booking.vehicleName} • ${booking.status.toUpperCase()}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreGrid() {
    final categoriesAsync = ref.watch(homeCategoriesProvider);

    return Padding(
      padding: ResponsiveLayout.responsivePadding(context, horizontal: 20, vertical: 24).copyWith(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Explore Services', style: TextStyle(fontSize: ResponsiveLayout.responsiveFontSize(context, 18), fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              GestureDetector(onTap: () { HapticFeedback.lightImpact(); context.go('/main/explore'); }, child: const Text(AppStrings.viewAll, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primaryBlue))),
            ],
          ),
          const SizedBox(height: 16),
          categoriesAsync.when(
            data: (categories) {
              if (categories.isEmpty) return const SizedBox.shrink();
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveLayout.isTablet(context) ? 6 : 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final icon = IconHelper.getIcon(cat.icon);
                  const color = AppColors.primaryBlue; // Default theme color for grid
                  final route = _getCategoryRoute(cat.label);

                  return GestureDetector(
                    onTap: () {
                      if (route == '/bike-service') {
                        final bikes = ref.read(allVehiclesProvider).where((v) => v.type == 'Bike' || v.type == 'EV Bike').toList();
                        if (bikes.isNotEmpty) ref.read(vehicleProvider.notifier).setVehicle(bikes.first);
                      } else if (route == '/car-service') {
                        final cars = ref.read(allVehiclesProvider).where((v) => v.type == 'Car').toList();
                        if (cars.isNotEmpty) ref.read(vehicleProvider.notifier).setVehicle(cars.first);
                      }
                      context.push(route);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, color: color, size: ResponsiveLayout.isSmallPhone(context) ? 18 : 22),
                          const SizedBox(height: 8),
                          Text(
                            cat.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: ResponsiveLayout.responsiveFontSize(context, 10),
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate(delay: (200 + index * 50).ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0));
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error loading categories: $err')),
          ),
        ],
      ),
    );
  }

  String _getCategoryRoute(String label) {
    switch (label.toLowerCase()) {
      case 'repair': return '/select-service';
      case 'rentals': return '/rentals-selection';
      case 'ev service': return '/select-service';
      default: return '/main/explore';
    }
  }

  Widget _buildOffersCarousel() {
    final offersAsync = ref.watch(homeOffersProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ref.watch(l10nProvider).get('active_offers'), style: GoogleFonts.outfit(fontSize: ResponsiveLayout.responsiveFontSize(context, 20), fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                GestureDetector(onTap: () { HapticFeedback.lightImpact(); context.push('/loyalty'); }, child: const Text(AppStrings.viewAll, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primaryBlue))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          offersAsync.when(
            data: (offers) {
              if (offers.isEmpty) return const SizedBox.shrink();
              return CarouselSlider(
                items: offers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final offer = entry.value;
                  final colors = [
                    [AppColors.primaryBlueDark, AppColors.primaryBlue],
                    [const Color(0xFF065F46), const Color(0xFF10B981)],
                    [AppColors.accentOrange, AppColors.accentAmber]
                  ];
                  return InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Clipboard.setData(ClipboardData(text: offer.cta));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Offer code ${offer.cta} copied!'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: colors[index % 3][0],
                      ));
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: colors[index % 3],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: colors[index % 3][0].withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(offer.title, style: GoogleFonts.outfit(fontSize: ResponsiveLayout.responsiveFontSize(context, 22), fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                            const SizedBox(height: 8),
                            Text(offer.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: ResponsiveLayout.responsiveFontSize(context, 13), fontWeight: FontWeight.w400, color: Colors.white.withValues(alpha: 0.9))),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: Text('USE CODE: ${offer.cta}', style: GoogleFonts.outfit(fontSize: ResponsiveLayout.responsiveFontSize(context, 11), fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.0)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: ResponsiveLayout.responsiveHeight(context, 22),
                  viewportFraction: 0.9,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                  enlargeCenterPage: true,
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error loading offers: $err')),
          ).animate(delay: 800.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildMoreTile(BuildContext context, String label, IconData icon, Color color, String route) {
    final double padding = ResponsiveLayout.responsivePadding(context, horizontal: 20).horizontal;
    return SizedBox(
      width: (MediaQuery.of(context).size.width - padding - 24.5) / 3,
      child: GestureDetector(
        onTap: () => context.push(route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, String label, IconData icon, Color color, String route) {
    final double padding = ResponsiveLayout.responsivePadding(context, horizontal: 20).horizontal;
    return SizedBox(
      width: (MediaQuery.of(context).size.width - padding - 24.5) / 3,
      child: GestureDetector(
        onTap: () => context.push(route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

