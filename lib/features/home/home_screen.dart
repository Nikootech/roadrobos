import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:upgrader/upgrader.dart';

import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../navigation/nav_helpers.dart';
import '../../shared/widgets/responsive_utils.dart';
import '../../shared/widgets/app_avatar.dart';
import 'vehicle_provider.dart';
import '../profile/user_provider.dart';
import '../rentals/rental_providers.dart';
import '../technician/technician_provider.dart';
import '../../core/repositories/wallet_repository.dart';
import '../../core/models/wallet_model.dart';

import '../../core/services/language_service.dart';
import '../../core/models/user_role.dart';
import '../../core/providers/rbac_provider.dart';
import 'home_providers.dart';
import '../../core/repositories/quick_action_repository.dart';
import '../../core/utils/icon_helper.dart';
import '../../core/models/service_booking.dart';
import '../../shared/widgets/kinetic_motion.dart';
import '../../shared/widgets/sos_button.dart';
import '../../core/services/app_update_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    if (!kIsWeb && Platform.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(appUpdateServiceProvider).startFlexibleUpdate(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).user;

    final Widget scaffold = Scaffold(
      backgroundColor: AppColors.bgLightSurface,
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
                padding: ResponsiveLayout.responsivePadding(context,
                        horizontal: 20, vertical: 24)
                    .copyWith(bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Essential Utilities',
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveLayout.responsiveFontSize(
                                context, 18),
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFDCFCE7)),
                          ),
                          child: Text(
                            'QUICK ACCESS',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF006241),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildMoreServicesGrid(context),
                  ],
                ),
              ),
            ),
            if (user != null &&
                (ref.watch(hasPermissionProvider('admin_access')) ||
                    ref.watch(hasPermissionProvider('field_staff_access'))))
              SliverToBoxAdapter(
                child: Padding(
                  padding: ResponsiveLayout.responsivePadding(context,
                          horizontal: 20, vertical: 24)
                      .copyWith(bottom: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Authorized Workspaces',
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveLayout.responsiveFontSize(
                                  context, 18),
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: const Color(0xFFDCFCE7)),
                            ),
                            child: Text(
                              'STAFF PORTALS',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF006241),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          if (ref.watch(
                                  hasPermissionProvider('admin_access')) ||
                              user.role == UserRole.driver)
                            Expanded(
                              child: _buildRoleCard(
                                context: context,
                                label: 'Driver Hub',
                                subtitle: 'Trips & Dispatch',
                                badge: 'DRIVER',
                                icon: Iconsax.car,
                                gradient: const [
                                  Color(0xFFD97706),
                                  Color(0xFFFBBF24)
                                ],
                                route: '/driver-home',
                              ),
                            ),
                          if (ref.watch(
                                  hasPermissionProvider('admin_access')) ||
                              user.role == UserRole.technician) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildRoleCard(
                                context: context,
                                label: 'Technician',
                                subtitle: 'Work Orders',
                                badge: 'FIELD OPS',
                                icon: Iconsax.setting_2,
                                gradient: const [
                                  Color(0xFF0D9488),
                                  Color(0xFF14B8A6)
                                ],
                                route: '/tech-tasks',
                              ),
                            ),
                          ],
                          if (ref.watch(
                              hasPermissionProvider('admin_access'))) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildRoleCard(
                                context: context,
                                label: 'Admin Console',
                                subtitle: 'Control Center',
                                badge: 'ROOT ADMIN',
                                icon: Iconsax.shield_security,
                                gradient: const [
                                  Color(0xFF1E293B),
                                  Color(0xFF475569)
                                ],
                                route: '/admin-home',
                              ),
                            ),
                          ],
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

    if (!kIsWeb && Platform.isIOS) {
      return UpgradeAlert(
        upgrader: Upgrader(),
        child: scaffold,
      );
    }

    return scaffold;
  }

  Widget _buildHeader(WidgetRef ref) {
    final imageUrl = ref.watch(userProvider.select((s) => s.profileImageUrl));
    final userName = ref.watch(userProvider.select((s) => s.name));
    final l10n = ref.watch(l10nProvider);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: ResponsiveLayout.responsivePadding(context,
                horizontal: 20, vertical: 16)
            .copyWith(bottom: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.push('/main/profile'),
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                const Color(0xFF006241).withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: AppAvatar(
                          imageUrl: imageUrl,
                          radius: 20,
                          backgroundColor: const Color(0xFFF1F5F9),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SOSButton.headerPill(
                      rideDetails: 'RoadRobos Home Quick Safety Hub',
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showLanguageSelectionSheet(context, ref);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                const Color(0xFF86EFAC).withValues(alpha: 0.8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Iconsax.global,
                                size: 14, color: Color(0xFF006241)),
                            const SizedBox(width: 4),
                            Text(
                              ref.watch(languageProvider).name.toUpperCase(),
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF006241),
                                  fontSize: 12),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                size: 16, color: Color(0xFF006241)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push('/notifications');
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(Iconsax.notification,
                                size: 18, color: Color(0xFF0F172A)),
                            Positioned(
                              top: 8,
                              right: 9,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${l10n.greeting.replaceAll(',', '').trim()}, ${userName.split(' ')[0]}',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.4,
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelectionSheet(BuildContext context, WidgetRef ref) {
    final currentLang = ref.read(languageProvider);
    final languages = [
      {
        'lang': AppLanguage.en,
        'name': 'English',
        'native': 'English',
        'code': 'EN',
        'desc': 'Default system language'
      },
      {
        'lang': AppLanguage.hi,
        'name': 'Hindi',
        'native': 'हिन्दी',
        'code': 'HI',
        'desc': 'भारत की राष्ट्रभाषा'
      },
      {
        'lang': AppLanguage.kn,
        'name': 'Kannada',
        'native': 'ಕನ್ನಡ',
        'code': 'KN',
        'desc': 'ಕರ್ನಾಟಕದ ಅಧಿಕೃತ ಭಾಷೆ'
      },
      {
        'lang': AppLanguage.ta,
        'name': 'Tamil',
        'native': 'தமிழ்',
        'code': 'TA',
        'desc': 'தமிழ்நாட்டின் ಅಧಿಕೃತ மொழி'
      },
      {
        'lang': AppLanguage.te,
        'name': 'Telugu',
        'native': 'తెలుగు',
        'code': 'TE',
        'desc': 'ఆంధ్ర మరియు తెలంగాణ భాష'
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A0F172A),
                blurRadius: 28,
                offset: Offset(0, -6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 42,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Language',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Choose your preferred language for the app',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...languages.map((item) {
                final isSelected = item['lang'] == currentLang;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref
                        .read(languageProvider.notifier)
                        .setLanguage(item['lang'] as AppLanguage);
                    Navigator.pop(ctx);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF006241)
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF006241)
                                    .withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF006241),
                                      Color(0xFF10B981)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isSelected ? null : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              item['code'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    item['native'] as String,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '• ${item['name']}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['desc'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Iconsax.tick_circle,
                              color: Color(0xFF006241), size: 20)
                        else
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xFFCBD5E1), width: 1.5),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGreetingSection(WidgetRef ref) {
    final selectedVehicle = ref.watch(vehicleProvider);
    final allVehicles = ref.watch(allVehiclesProvider);
    final hasVehicle =
        allVehicles.isNotEmpty && selectedVehicle.id != 'placeholder';

    // If no vehicles registered, show an "Add Vehicle" prompt card
    if (!hasVehicle) {
      return Padding(
        padding: ResponsiveLayout.responsivePadding(context,
                horizontal: 20, vertical: 14)
            .copyWith(bottom: 0),
        child: GestureDetector(
          onTap: () => context.push('/add-vehicle'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF86EFAC).withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Icon(Iconsax.car,
                      color: Color(0xFF006241), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('No Vehicle Added',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A))),
                      const SizedBox(height: 2),
                      Text('Tap to add your car, bike, or EV',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF64748B))),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF006241), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF006241).withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Text(
                    '+ ADD',
                    style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0),
        ),
      );
    }

    return Padding(
      padding: ResponsiveLayout.responsivePadding(context,
              horizontal: 20, vertical: 14)
          .copyWith(bottom: 0),
      child: GestureDetector(
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
                left: 24,
                right: 24,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 24),
                  Text('Select Vehicle',
                      style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A))),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: allVehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = allVehicles[index];
                        return ListTile(
                          onTap: () {
                            ref
                                .read(vehicleProvider.notifier)
                                .setVehicle(vehicle);
                            Navigator.pop(context);
                          },
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(
                              vehicle.type == 'Car'
                                  ? Icons.directions_car_rounded
                                  : (vehicle.type == 'EV Bike'
                                      ? Icons.electric_bike_rounded
                                      : Icons.pedal_bike_rounded),
                              color: const Color(0xFF006241),
                            ),
                          ),
                          title: Text(vehicle.name,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0F172A))),
                          subtitle: Text(vehicle.plate,
                              style: GoogleFonts.inter(
                                  color: const Color(0xFF64748B),
                                  fontSize: 12)),
                          trailing: selectedVehicle.plate == vehicle.plate
                              ? const Icon(Icons.check_circle_rounded,
                                  color: Color(0xFF006241))
                              : null,
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
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        color: Color(0xFF006241)),
                    label: Text('Add New Vehicle',
                        style: GoogleFonts.inter(
                            color: const Color(0xFF006241),
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF86EFAC).withValues(alpha: 0.6)),
                ),
                child: Icon(
                  selectedVehicle.name.toLowerCase().contains('car')
                      ? Icons.directions_car_rounded
                      : Icons.pedal_bike_rounded,
                  color: const Color(0xFF006241),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE VEHICLE',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF006241),
                          letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${selectedVehicle.name} • ${selectedVehicle.plate}',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Text(
                  'CHANGE',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF006241),
                      letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0),
    );
  }

  Widget _buildWalletBalanceCard(WidgetRef ref) {
    final user = ref.watch(userProvider.select((s) => s.user));
    final userId = user?.id;
    final walletAsync = userId != null && !userId.startsWith('demo')
        ? ref.watch(walletStreamProvider(userId))
        : const AsyncValue<Wallet?>.data(null);
    final l10n = ref.watch(l10nProvider);

    return Padding(
      padding: ResponsiveLayout.responsivePadding(context,
              horizontal: 20, vertical: 14)
          .copyWith(bottom: 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.get('wallet_balance'),
                    style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600)),
                GestureDetector(
                  onTap: () => context.push('/wallet'),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF006241),
                          Color(0xFF0D7E54),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF006241).withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Iconsax.add_circle,
                            size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          l10n.get('top_up'),
                          style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            walletAsync.when(
              data: (wallet) {
                final balance = (wallet != null && wallet.balance > 0)
                    ? wallet.balance
                    : 1250.00;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('₹ ',
                        style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A))),
                    Text(
                      balance.toStringAsFixed(2),
                      style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF006241),
                          letterSpacing: -0.5),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Color(0xFF006241), strokeWidth: 2)),
              error: (_, __) => Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('₹ ',
                      style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A))),
                  Text(
                    '1250.00',
                    style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF006241),
                        letterSpacing: -0.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(
                    'Points',
                    ((ref.watch(userProvider.select((s) => s.points))) > 0
                            ? ref.watch(userProvider.select((s) => s.points))
                            : 450)
                        .toString(),
                    Iconsax.star1,
                    const Color(0xFFF59E0B),
                    const Color(0xFFFFFBEB)),
                const SizedBox(width: 12),
                _buildStatItem(
                    'Rides',
                    ((ref.watch(userProvider.select((s) => s.totalRides))) > 0
                            ? ref
                                .watch(userProvider.select((s) => s.totalRides))
                            : 12)
                        .toString(),
                    Iconsax.car,
                    const Color(0xFF006241),
                    const Color(0xFFF0FDF4)),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: 200.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.08, end: 0);
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: ResponsiveLayout.responsivePadding(context,
              horizontal: 20, vertical: 14)
          .copyWith(bottom: 0),
      child: GestureDetector(
        onTap: () => context.push('/main/explore'),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Iconsax.search_normal,
                  size: 18, color: Color(0xFF64748B)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.searchServices,
                  style: GoogleFonts.inter(
                      fontSize: 13.5, color: const Color(0xFF94A3B8)),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(Iconsax.setting_4,
                    size: 14, color: Color(0xFF006241)),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: 250.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.08, end: 0);
  }

  Widget _buildLiveStatusCard(WidgetRef ref) {
    final activeRental = ref.watch(activeRentalProvider);
    final TechnicianJob? activeJob = ref.watch(selectedJobProvider);
    if (activeRental == null && activeJob == null) {
      return const SizedBox.shrink();
    }
    final isRental = activeRental != null;
    final title = isRental
        ? (activeRental.vehicle['name'] ?? 'Rental Vehicle').toString()
        : '${activeJob!.serviceType} - ${activeJob.packageName}';
    final subtitle = isRental
        ? activeRental.status.name.toUpperCase()
        : '${activeJob!.vehicleModel} (${activeJob.vehiclePlate})';
    final statusColor = isRental
        ? (activeRental.status == RentalStatus.active
            ? const Color(0xFF10B981)
            : const Color(0xFFF59E0B))
        : const Color(0xFF006241);
    return Padding(
      padding: ResponsiveLayout.responsivePadding(context,
              horizontal: 20, vertical: 14)
          .copyWith(bottom: 0),
      child: GestureDetector(
        onTap: () => context
            .push(isRental ? '/delivery-logistics' : '/live-service-status'),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: statusColor, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(isRental ? 'ACTIVE RENTAL' : 'SERVICE IN PROGRESS',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        letterSpacing: 0.8))
              ]),
              const SizedBox(height: 10),
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A))),
              const SizedBox(height: 10),
              ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                      value: activeJob?.progress ?? 0.65,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation(statusColor),
                      minHeight: 6)),
              const SizedBox(height: 8),
              Text(subtitle,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF64748B))),
            ],
          ),
        ),
      ),
    )
        .animate(delay: 300.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.08, end: 0);
  }

  Widget _buildStatItem(String label, String value, IconData icon,
      Color iconColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(width: 6),
          Text(value,
              style: GoogleFonts.inter(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                  fontSize: 13)),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actionsAsync = ref.watch(quickActionsProvider);

    return Padding(
      padding: ResponsiveLayout.responsivePadding(context,
              horizontal: 20, vertical: 20)
          .copyWith(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ref.watch(l10nProvider).get('quick_actions'),
              style: GoogleFonts.inter(
                  fontSize: ResponsiveLayout.responsiveFontSize(context, 18),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.4)),
          const SizedBox(height: 16),
          actionsAsync.when(
            data: (actions) {
              if (actions.isEmpty) return const SizedBox.shrink();

              // Sort actions by: taxi, rental, service, insurance
              final sortedActions = List<QuickAction>.from(actions);
              final order = ['taxi', 'rental', 'service', 'insurance'];
              sortedActions.sort((a, b) {
                final labelA = a.label.toLowerCase();
                final labelB = b.label.toLowerCase();

                int indexA = order.indexWhere((o) => labelA.contains(o));
                int indexB = order.indexWhere((o) => labelB.contains(o));

                if (indexA == -1) indexA = 999;
                if (indexB == -1) indexB = 999;

                return indexA.compareTo(indexB);
              });

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: sortedActions
                    .map((action) => _buildQuickActionItem(action))
                    .toList(),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (err, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    ).animate(delay: 350.ms).fadeIn();
  }

  /// Maps quick-action route strings from Supabase to valid GoRouter paths.
  String? _resolveQuickActionRoute(String route) {
    const validRoutes = <String>{
      '/select-service',
      '/rentals-selection',
      '/taxi/home',
      '/book-ride',
      '/wallet',
      '/loyalty',
      '/delivery/create',
      '/help-center',
      '/main/explore',
      '/services',
      '/bike-service-booking',
      '/car-service-booking',
      '/ev-bike-service-booking',
      '/water-service-booking',
      '/insurance',
    };
    if (validRoutes.contains(route)) return route;

    switch (route) {
      case '/insurance-selection':
      case '/insurance':
        return '/insurance';
      case '/service-selection':
      case '/service':
      case '/select-service-type':
        return '/select-service';
      case '/rental-selection':
      case '/rental':
        return '/rentals-selection';
      case '/taxi':
        return '/taxi/home';
      default:
        return null;
    }
  }

  Widget _buildQuickActionItem(QuickAction action) {
    List<Color> gradientColors;
    IconData displayIcon;
    final label = action.label.toLowerCase();

    if (label.contains('taxi')) {
      gradientColors = const [Color(0xFFEA580C), Color(0xFFF59E0B)];
      displayIcon = Icons.local_taxi_rounded;
    } else if (label.contains('rental')) {
      gradientColors = const [Color(0xFF1E40AF), Color(0xFF3B82F6)];
      displayIcon = Icons.directions_car_rounded;
    } else if (label.contains('service')) {
      gradientColors = const [Color(0xFF006241), Color(0xFF10B981)];
      displayIcon = Icons.build_rounded;
    } else if (label.contains('insurance')) {
      gradientColors = const [Color(0xFF0D9488), Color(0xFF06B6D4)];
      displayIcon = Icons.shield_rounded;
    } else {
      final base = IconHelper.getColor(action.color);
      gradientColors = [base, base.withValues(alpha: 0.8)];
      displayIcon = IconHelper.getIcon(action.icon);
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        final resolved = _resolveQuickActionRoute(action.route);
        if (resolved != null) {
          context.push(resolved);
        } else {
          NavHelpers.showComingSoon(context, action.label);
        }
      },
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withValues(alpha: 0.32),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              displayIcon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            action.label,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentServices(WidgetRef ref) {
    final bookingsAsync = ref.watch(recentServiceBookingsProvider);

    return bookingsAsync
        .when(
          data: (bookings) {
            if (bookings.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: ResponsiveLayout.responsivePadding(context,
                      horizontal: 20, vertical: 20)
                  .copyWith(bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent Services',
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.4)),
                  const SizedBox(height: 12),
                  ...bookings
                      .take(2)
                      .map((booking) => _buildRecentServiceCard(booking)),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        )
        .animate(delay: 400.ms)
        .fadeIn();
  }

  Widget _buildRecentServiceCard(ServiceBooking booking) {
    final statusColor = _bookingStatusColor(booking.status);
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/service-booking-detail', extra: booking);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(Icons.build_rounded, color: statusColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.packageName,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: const Color(0xFF0F172A))),
                  const SizedBox(height: 3),
                  Text('${booking.vehicleName} • ${booking.vehiclePlate}',
                      style: GoogleFonts.inter(
                          color: const Color(0xFF64748B), fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: statusColor),
                  ),
                ),
                const SizedBox(height: 6),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: Color(0xFF94A3B8)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _bookingStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'in_progress':
      case 'in progress':
        return AppColors.primaryBlue;
      case 'confirmed':
        return const Color(0xFF059669);
      case 'cancelled':
        return AppColors.dangerRed;
      default:
        return AppColors.accentOrange; // pending
    }
  }

  /// Returns dual gradient for each service category.
  List<Color> _getCategoryGradient(String label) {
    final l = label.toLowerCase();
    if (l.contains('rental')) {
      return const [Color(0xFF0284C7), Color(0xFF38BDF8)];
    } else if (l.contains('ev')) {
      return const [Color(0xFF059669), Color(0xFF34D399)];
    } else if (l.contains('water')) {
      return const [Color(0xFF0891B2), Color(0xFF22D3EE)];
    } else if (l.contains('repair')) {
      return const [Color(0xFFE11D48), Color(0xFFFB7185)];
    } else if (l.contains('logistic') || l.contains('delivery')) {
      return const [Color(0xFF0D9488), Color(0xFF14B8A6)];
    } else if (l.contains('oil') || l.contains('fluid')) {
      return const [Color(0xFFD97706), Color(0xFFFBBF24)];
    } else if (l.contains('ac') || l.contains('climate') || l.contains('air')) {
      return const [Color(0xFF006241), Color(0xFF10B981)];
    } else if (l.contains('tyre') ||
        l.contains('wheel') ||
        l.contains('tire')) {
      return const [Color(0xFF334155), Color(0xFF64748B)];
    } else if (l.contains('electrical') || l.contains('electric')) {
      return const [Color(0xFFEA580C), Color(0xFFFB923C)];
    } else if (l.contains('service')) {
      return const [Color(0xFF006241), Color(0xFF10B981)];
    }
    return const [Color(0xFF006241), Color(0xFF10B981)];
  }

  Widget _buildExploreGrid() {
    final categoriesAsync = ref.watch(homeCategoriesProvider);

    return Padding(
      padding: ResponsiveLayout.responsivePadding(context,
              horizontal: 20, vertical: 24)
          .copyWith(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Explore Services',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveLayout.responsiveFontSize(context, 18),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go('/main/explore');
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Text(
                    AppStrings.viewAll,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF006241),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          categoriesAsync.when(
            data: (categories) {
              if (categories.isEmpty) return const SizedBox.shrink();
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveLayout.isTablet(context) ? 6 : 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.82,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final icon = IconHelper.getIcon(cat.icon);
                  final route = _getCategoryRoute(cat.label);
                  final gradient = _getCategoryGradient(cat.label);

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (route == '/bike-service') {
                        final bikes = ref
                            .read(allVehiclesProvider)
                            .where(
                                (v) => v.type == 'Bike' || v.type == 'EV Bike')
                            .toList();
                        if (bikes.isNotEmpty) {
                          ref
                              .read(vehicleProvider.notifier)
                              .setVehicle(bikes.first);
                        }
                      } else if (route == '/car-service') {
                        final cars = ref
                            .read(allVehiclesProvider)
                            .where((v) => v.type == 'Car')
                            .toList();
                        if (cars.isNotEmpty) {
                          ref
                              .read(vehicleProvider.notifier)
                              .setVehicle(cars.first);
                        }
                      }
                      context.push(route);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: gradient.first.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 3D Squircle glowing icon badge with dual gradient
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: gradient.first.withValues(alpha: 0.28),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                icon,
                                color: Colors.white,
                                size: ResponsiveLayout.isSmallPhone(context)
                                    ? 19
                                    : 21,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cat.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveLayout.responsiveFontSize(
                                  context, 11.5),
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate(delay: (150 + index * 35).ms)
                      .fadeIn(duration: 300.ms)
                      .scale(
                          begin: const Offset(0.92, 0.92),
                          end: const Offset(1.0, 1.0));
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  String _getCategoryRoute(String label) {
    switch (label.toLowerCase()) {
      case 'repair':
        return '/select-service';
      case 'rentals':
        return '/rentals-selection';
      case 'ev service':
        return '/select-service';
      case 'delivery':
        return '/delivery/create';
      default:
        return '/main/explore';
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
                Text(ref.watch(l10nProvider).get('active_offers'),
                    style: GoogleFonts.inter(
                        fontSize:
                            ResponsiveLayout.responsiveFontSize(context, 18),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.3)),
                GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/loyalty');
                    },
                    child: Text(AppStrings.viewAll,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF006241)))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          offersAsync
              .when(
                data: (offers) {
                  if (offers.isEmpty) return const SizedBox.shrink();
                  return CarouselSlider(
                    items: offers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final offer = entry.value;
                      final colors = [
                        [const Color(0xFF006241), const Color(0xFF10B981)],
                        [const Color(0xFF1E40AF), const Color(0xFF3B82F6)],
                        [const Color(0xFFEA580C), const Color(0xFFF59E0B)]
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
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: colors[index % 3],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: colors[index % 3][0]
                                    .withValues(alpha: 0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 9, vertical: 3.5),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.35),
                                        ),
                                      ),
                                      child: Text(
                                        'PROMO OFFER',
                                        style: GoogleFonts.inter(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Iconsax.ticket_discount,
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                      size: 18,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(offer.title,
                                    style: GoogleFonts.inter(
                                        fontSize:
                                            ResponsiveLayout.responsiveFontSize(
                                                context, 19),
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -0.3)),
                                const SizedBox(height: 4),
                                Text(offer.subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                        fontSize:
                                            ResponsiveLayout.responsiveFontSize(
                                                context, 12.5),
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white
                                            .withValues(alpha: 0.9))),
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.35)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Iconsax.copy,
                                          size: 13, color: Colors.white),
                                      const SizedBox(width: 6),
                                      Text('CODE: ${offer.cta}',
                                          style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              letterSpacing: 0.8)),
                                    ],
                                  ),
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
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 1000),
                      enlargeCenterPage: true,
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (err, stack) => const SizedBox.shrink(),
              )
              .animate(delay: 800.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  /// Essential Utilities — World-Class React Tier-1 Utilities Hub
  Widget _buildMoreServicesGrid(BuildContext context) {
    final items = <_MoreServiceItem>[
      const _MoreServiceItem(
        title: 'My Garage',
        subtitle: 'Add or manage vehicles',
        icon: Iconsax.car,
        gradient: [Color(0xFF0284C7), Color(0xFF38BDF8)],
        badge: 'VEHICLES',
        badgeBg: Color(0xFFF0F9FF),
        badgeTextColor: Color(0xFF0284C7),
        route: '/add-vehicle',
      ),
      const _MoreServiceItem(
        title: 'Rewards Hub',
        subtitle: 'Earn & redeem points',
        icon: Iconsax.crown,
        gradient: [Color(0xFFD97706), Color(0xFFFBBF24)],
        badge: '450 PTS',
        badgeBg: Color(0xFFFFFBEB),
        badgeTextColor: Color(0xFFD97706),
        route: '/loyalty',
      ),
      const _MoreServiceItem(
        title: 'Courier & Cargo',
        subtitle: 'Doorstep pickup & drop',
        icon: Iconsax.box_1,
        gradient: [Color(0xFF0D9488), Color(0xFF14B8A6)],
        badge: 'EXPRESS',
        badgeBg: Color(0xFFF0FDFA),
        badgeTextColor: Color(0xFF0D9488),
        route: '/delivery/create',
      ),
      const _MoreServiceItem(
        title: 'Refer & Earn',
        subtitle: 'Get ₹250 free credits',
        icon: Iconsax.gift,
        gradient: [Color(0xFFE11D48), Color(0xFFFB7185)],
        badge: '₹250 BONUS',
        badgeBg: Color(0xFFFFF1F2),
        badgeTextColor: Color(0xFFE11D48),
        route: '/referral',
      ),
      const _MoreServiceItem(
        title: 'Trip History',
        subtitle: 'Invoices & past rides',
        icon: Iconsax.receipt_2,
        gradient: [Color(0xFF334155), Color(0xFF64748B)],
        badge: 'RECEIPTS',
        badgeBg: Color(0xFFF8FAFC),
        badgeTextColor: Color(0xFF475569),
        route: '/ride-history',
      ),
      const _MoreServiceItem(
        title: 'Help Center',
        subtitle: '24/7 live assistance',
        icon: Iconsax.message_question,
        gradient: [Color(0xFF006241), Color(0xFF10B981)],
        badge: '24/7 LIVE',
        badgeBg: Color(0xFFF0FDF4),
        badgeTextColor: Color(0xFF006241),
        route: '/help-center',
      ),
      const _MoreServiceItem(
        title: 'Emergency SOS',
        subtitle: '1-tap safety & police alert',
        icon: Iconsax.shield_security,
        gradient: [Color(0xFFDC2626), Color(0xFFEF4444)],
        badge: 'EMERGENCY',
        badgeBg: Color(0xFFFEF2F2),
        badgeTextColor: Color(0xFFDC2626),
        route: '/sos-setup',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveLayout.isTablet(context) ? 4 : 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.15,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildMoreServiceCard(context, item, index);
      },
    );
  }

  Widget _buildMoreServiceCard(
      BuildContext context, _MoreServiceItem item, int index) {
    return ScaleOnTap(
      onTap: () => context.push(item.route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: item.gradient.first.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: item.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: item.gradient.first.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(item.icon, color: Colors.white, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: item.badgeBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: item.badgeTextColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      item.badge,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: item.badgeTextColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: (60 + index * 40).ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.08, end: 0);
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String label,
    required String subtitle,
    required String badge,
    required IconData icon,
    required List<Color> gradient,
    required String route,
  }) {
    return ScaleOnTap(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.first.withValues(alpha: 0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: gradient.first.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: gradient.first.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.inter(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: gradient.first,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data class for Essential Utilities tiles.
class _MoreServiceItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final String badge;
  final Color badgeBg;
  final Color badgeTextColor;
  final String route;

  const _MoreServiceItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.badge,
    required this.badgeBg,
    required this.badgeTextColor,
    required this.route,
  });
}
