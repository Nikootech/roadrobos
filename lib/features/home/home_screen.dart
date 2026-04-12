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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<Map<String, dynamic>> _services = [
    {'icon': Icons.build_rounded, 'label': 'Service', 'color': const Color(0xFF3B82F6), 'route': '/select-service'},
    {'icon': Icons.car_rental_rounded, 'label': 'Rentals', 'color': const Color(0xFF8B5CF6), 'route': '/rentals'},
    {'icon': Icons.local_taxi_rounded, 'label': 'Taxi', 'color': const Color(0xFF22C55E), 'route': '/book-ride'},
    {'icon': Icons.wallet_rounded, 'label': 'Wallet', 'color': const Color(0xFF06B6D4), 'route': '/wallet'},
    {'icon': Icons.location_on_rounded, 'label': 'Track', 'color': const Color(0xFF6366F1), 'route': '/live-vehicle-tracking'},
    {'icon': Icons.star_rounded, 'label': 'Reviews', 'color': const Color(0xFFEF4444), 'route': '/service-feedback'},
    {'icon': Icons.inventory_2_rounded, 'label': 'Parts', 'color': const Color(0xFFF59E0B), 'route': '/tech-spare-parts'},
    {'icon': Icons.receipt_long_rounded, 'label': 'Invoices', 'color': const Color(0xFF10B981), 'route': '/wallet/billing-invoice'},
  ];

  final List<Map<String, String>> _offers = [
    {'title': '15% Off First Service', 'desc': 'New users get 15% discount on their first service booking', 'code': 'FIRST15'},
    {'title': 'Free AC Check-up', 'desc': 'Complimentary AC diagnostics with any service package', 'code': 'FREEAC'},
    {'title': '₹200 Off on Brakes', 'desc': 'Get flat ₹200 off on brake pad replacement this month', 'code': 'BRAKE200'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          ref.invalidate(userProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(ref)),
            SliverToBoxAdapter(child: _buildGreetingSection(ref)),
            SliverToBoxAdapter(child: _buildWalletBalanceCard(ref)),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildLiveStatusCard(ref)),
            SliverToBoxAdapter(child: _buildQuickActionsSection()),
            SliverToBoxAdapter(child: _buildOffersCarousel()),
            SliverToBoxAdapter(
              child: Padding(
                padding: ResponsiveLayout.responsivePadding(context, horizontal: 20, vertical: 20).copyWith(bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('More Services', style: GoogleFonts.outfit(fontSize: ResponsiveLayout.responsiveFontSize(context, 20), fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildMoreTile(context, 'Add Vehicle', Icons.add_circle_outline_rounded, const Color(0xFF3B82F6), '/add-vehicle'),
                        const SizedBox(width: 12),
                        _buildMoreTile(context, 'Loyalty', Icons.card_membership_rounded, const Color(0xFFF97316), '/loyalty'),
                        const SizedBox(width: 12),
                        _buildMoreTile(context, 'Help', Iconsax.message_question, const Color(0xFF8B5CF6), '/help-center'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildMoreTile(context, 'History', Icons.history_rounded, const Color(0xFFF97316), '/ride-history'),
                        const SizedBox(width: 12),
                        _buildMoreTile(context, 'Referral', Icons.card_giftcard_rounded, const Color(0xFFEC4899), '/referral'),
                        const SizedBox(width: 12),
                        _buildMoreTile(context, 'Emergency', Iconsax.shield_slash, AppColors.dangerRed, '/sos-setup'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: ResponsiveLayout.responsivePadding(context, horizontal: 20, vertical: 24).copyWith(bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Switch View', style: GoogleFonts.outfit(fontSize: ResponsiveLayout.responsiveFontSize(context, 20), fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildRoleCard(context, 'Driver', Icons.local_taxi_rounded, const Color(0xFF22C55E), '/driver-home'),
                        const SizedBox(width: 12),
                        _buildRoleCard(context, 'Technician', Icons.build_rounded, const Color(0xFFF97316), '/tech-tasks'),
                        const SizedBox(width: 12),
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
    final user = ref.watch(userProvider);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: ResponsiveLayout.responsivePadding(context, horizontal: 20, vertical: 16).copyWith(bottom: 0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.push('/main/profile'),
              child: AppAvatar(
                imageUrl: user.profileImageUrl,
                radius: 22,
                backgroundColor: Colors.white,
              ),
            ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
            const Spacer(),
            // Language Toggle
            GestureDetector(
              onTap: () {
                final current = ref.read(languageProvider);
                ref.read(languageProvider.notifier).setLanguage(
                  current == AppLanguage.en ? AppLanguage.hi : AppLanguage.en,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ref.watch(languageProvider) == AppLanguage.en ? 'EN' : 'HI',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Iconsax.notification, size: 22, color: AppColors.textPrimary),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: AppColors.dangerRed, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 100.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
          ],
        ),
      ),
    );
  }



  Widget _buildGreetingSection(WidgetRef ref) {
    final user = ref.watch(userProvider);
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
          Text(user.name.split(' ')[0], style: TextStyle(fontSize: ResponsiveLayout.responsiveFontSize(context, 28), fontWeight: FontWeight.w800, color: AppColors.textPrimary)).animate(delay: 100.ms).fadeIn(duration: 500.ms).slideX(begin: -0.05, end: 0),
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
                              trailing: selectedVehicle?.plate == vehicle.plate ? const Icon(Icons.check_circle_rounded, color: AppColors.successGreen) : null,
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
              decoration: BoxDecoration(color: AppColors.bgSkyLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1), width: 1)),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(selectedVehicle?.name.toLowerCase().contains('car') ?? false ? Icons.directions_car_rounded : Icons.pedal_bike_rounded, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(AppStrings.selectedVehicle, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
                        const SizedBox(height: 2),
                        Text('${selectedVehicle?.name ?? ''}  •  ${selectedVehicle?.plate ?? ''}', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
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
    final userId = ref.watch(userProvider).user?.id ?? 'demo';
    final walletAsync = ref.watch(walletStreamProvider(userId));
    final l10n = ref.watch(l10nProvider);

    return Padding(
      padding: ResponsiveLayout.responsivePadding(context, horizontal: 20, vertical: 16).copyWith(bottom: 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primaryBlue, AppColors.primaryBlueDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.get('wallet_balance'), style: TextStyle(fontSize: ResponsiveLayout.responsiveFontSize(context, 12), color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: walletAsync.when(
                      data: (wallet) => Text('₹ ${(wallet?.balance ?? 0.0).toStringAsFixed(2)}', style: TextStyle(fontSize: ResponsiveLayout.responsiveFontSize(context, 24), fontWeight: FontWeight.w700, color: Colors.white)),
                      loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                      error: (_, __) => const Text('₹ --', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.push('/wallet'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [const Icon(Icons.add_circle_outline_rounded, size: 18, color: Colors.white), const SizedBox(width: 8), Text(l10n.get('top_up'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))]),
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
    final activeJob = ref.watch(selectedJobProvider);
    if (activeRental == null && activeJob == null) return const SizedBox.shrink();
    final isRental = activeRental != null;
    final title = isRental ? activeRental.vehicle['name'] : '${activeJob!.serviceType} - ${activeJob.packageName}';
    final subtitle = isRental ? activeRental.status.name.toUpperCase() : '${activeJob!.vehicleModel} (${activeJob.vehiclePlate})';
    final statusColor = isRental ? (activeRental.status == RentalStatus.active ? AppColors.successGreen : AppColors.accentOrange) : AppColors.primaryBlue;
    return Padding(
      padding: ResponsiveLayout.responsivePadding(context, horizontal: 20, vertical: 16).copyWith(bottom: 0),
      child: GlassCard(
        onTap: () => context.push(isRental ? '/delivery-logistics' : '/live-service-status'),
        padding: const EdgeInsets.all(20),
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

  Widget _buildQuickActionsSection() {
    return Padding(
      padding: ResponsiveLayout.responsivePadding(context, horizontal: 20, vertical: 24).copyWith(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(ref.watch(l10nProvider).get('quick_actions'), style: TextStyle(fontSize: ResponsiveLayout.responsiveFontSize(context, 18), fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              GestureDetector(onTap: () { HapticFeedback.lightImpact(); context.go('/main/explore'); }, child: const Text(AppStrings.viewAll, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primaryBlue))),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveLayout.isTablet(context) ? 6 : 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _services.length,
            itemBuilder: (context, index) {
              final service = _services[index];
              final color = service['color'] as Color;
              return GestureDetector(
                onTap: () {
                  final route = service['route'] as String;
                  if (route == '/bike-service') {
                    final bikes = ref.read(allVehiclesProvider).where((v) => v.type == 'Bike' || v.type == 'EV Bike').toList();
                    if (bikes.isNotEmpty) ref.read(vehicleProvider.notifier).setVehicle(bikes.first);
                  } else if (route == '/car-service') {
                    final cars = ref.read(allVehiclesProvider).where((v) => v.type == 'Car').toList();
                    if (cars.isNotEmpty) ref.read(vehicleProvider.notifier).setVehicle(cars.first);
                  } else if (route == '/ev-bike-service') {
                    final evBikes = ref.read(allVehiclesProvider).where((v) => v.type == 'EV Bike').toList();
                    if (evBikes.isNotEmpty) {
                      ref.read(vehicleProvider.notifier).setVehicle(evBikes.first);
                    } else {
                      final bikes = ref.read(allVehiclesProvider).where((v) => v.type == 'Bike').toList();
                      if (bikes.isNotEmpty) ref.read(vehicleProvider.notifier).setVehicle(bikes.first);
                    }
                  } else if (route == '/water-service') {
                    // Default to Car for water service, but the screen has its own toggle
                    final cars = ref.read(allVehiclesProvider).where((v) => v.type == 'Car').toList();
                    if (cars.isNotEmpty) ref.read(vehicleProvider.notifier).setVehicle(cars.first);
                  }
                  context.push(route);
                },
                child: Container(
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(service['icon'] as IconData, color: color, size: ResponsiveLayout.isSmallPhone(context) ? 18 : 22), const SizedBox(height: 8), Text(service['label'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: ResponsiveLayout.responsiveFontSize(context, 10), fontWeight: FontWeight.w600, color: color))]),
                ),
              ).animate(delay: (200 + index * 50).ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOffersCarousel() {
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
          CarouselSlider(
            items: _offers.asMap().entries.map((entry) {
              final index = entry.key;
              final offer = entry.value;
              final colors = [[AppColors.primaryBlueDark, AppColors.primaryBlue], [const Color(0xFF065F46), const Color(0xFF10B981)], [AppColors.accentOrange, AppColors.accentAmber]];
              return InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(text: offer['code']!));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Offer code ${offer['code']} copied!'), behavior: SnackBarBehavior.floating, backgroundColor: colors[index % 3][0]));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(gradient: LinearGradient(colors: colors[index % 3], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: colors[index % 3][0].withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(offer['title']!, style: GoogleFonts.outfit(fontSize: ResponsiveLayout.responsiveFontSize(context, 22), fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        Text(offer['desc']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: ResponsiveLayout.responsiveFontSize(context, 13), fontWeight: FontWeight.w400, color: Colors.white.withOpacity(0.9))),
                        const SizedBox(height: 16),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.3))), child: Text('USE CODE: ${offer['code']}', style: GoogleFonts.outfit(fontSize: ResponsiveLayout.responsiveFontSize(context, 11), fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.0))),
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
              enlargeStrategy: CenterPageEnlargeStrategy.scale,
            ),
          ).animate(delay: 800.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildMoreTile(BuildContext context, String label, IconData icon, Color color, String route) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.push(route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
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
    return Expanded(
      child: GestureDetector(
        onTap: () => context.push(route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withOpacity(0.15), color.withOpacity(0.05)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
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

