import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_assets.dart';
import '../../shared/widgets/responsive_utils.dart';
import '../../shared/widgets/glass_card.dart';
import '../profile/user_provider.dart';
import '../rentals/rental_providers.dart';
import '../technician/technician_provider.dart';

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
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryBlue, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: CachedNetworkImage(
                    imageUrl: user.profileImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(baseColor: AppColors.bgLightGrey, highlightColor: Colors.white, child: Container(color: AppColors.bgLightGrey)),
                    errorWidget: (context, url, error) => const Icon(Icons.person, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
            const Spacer(),
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
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
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
    return Padding(
      padding: ResponsiveLayout.responsivePadding(context, horizontal: 20, vertical: 20).copyWith(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.goodMorning, style: TextStyle(fontSize: ResponsiveLayout.responsiveFontSize(context, 14), color: AppColors.textSecondary)).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 4),
          Text(user.name.split(' ')[0], style: TextStyle(fontSize: ResponsiveLayout.responsiveFontSize(context, 28), fontWeight: FontWeight.w800, color: AppColors.textPrimary)).animate(delay: 100.ms).fadeIn(duration: 500.ms).slideX(begin: -0.05, end: 0),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.go('/add-vehicle'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.bgSkyLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1), width: 1)),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Image.asset(AppAssets.creta, fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.selectedVehicle, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
                        SizedBox(height: 2),
                        Text('Hyundai Creta - MH 02 AB 1234', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
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
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wallet Balance', style: TextStyle(fontSize: ResponsiveLayout.responsiveFontSize(context, 12), color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('₹ 2,450.00', style: TextStyle(fontSize: ResponsiveLayout.responsiveFontSize(context, 24), fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.push('/wallet'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: const Row(children: [Icon(Icons.add_circle_outline_rounded, size: 18, color: Colors.white), SizedBox(width: 8), Text('Top Up', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))]),
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
    final activeJob = ref.watch(technicianProvider);
    if (activeRental == null && activeJob == null) return const SizedBox.shrink();
    final isRental = activeRental != null;
    final title = isRental ? activeRental.vehicle['name'] : 'Job Card: ${activeJob!.id}';
    final subtitle = isRental ? activeRental.status.name.toUpperCase() : activeJob!.status;
    final statusColor = isRental ? (activeRental.status == RentalStatus.active ? AppColors.successGreen : AppColors.accentOrange) : AppColors.primaryBlue;
    return Padding(
      padding: ResponsiveLayout.responsivePadding(context, horizontal: 20, vertical: 16).copyWith(bottom: 0),
      child: GlassCard(
        onTap: () => context.push(isRental ? '/delivery-logistics' : '/tech-job-card-details'),
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
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: 0.65, backgroundColor: AppColors.bgSkyLight, valueColor: AlwaysStoppedAnimation(statusColor), minHeight: 6)),
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
              Text(AppStrings.quickActions, style: TextStyle(fontSize: ResponsiveLayout.responsiveFontSize(context, 18), fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
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
                onTap: () => context.push(service['route'] as String),
                child: Container(
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.2))),
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
                Text(AppStrings.activeOffers, style: GoogleFonts.outfit(fontSize: ResponsiveLayout.responsiveFontSize(context, 20), fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
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
                  decoration: BoxDecoration(gradient: LinearGradient(colors: colors[index % 3], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: colors[index % 3][0].withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))]),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(offer['title']!, style: GoogleFonts.outfit(fontSize: ResponsiveLayout.responsiveFontSize(context, 22), fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        Text(offer['desc']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: ResponsiveLayout.responsiveFontSize(context, 13), fontWeight: FontWeight.w400, color: Colors.white.withValues(alpha: 0.9))),
                        const SizedBox(height: 16),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.3))), child: Text('USE CODE: ${offer['code']}', style: GoogleFonts.outfit(fontSize: ResponsiveLayout.responsiveFontSize(context, 11), fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.0))),
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
    return Expanded(
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

