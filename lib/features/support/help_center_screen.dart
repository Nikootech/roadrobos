import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const Map<String, List<Map<String, String>>> _faqData = {
    'Getting Started': [
      {
        'q': 'How do I book a ride?',
        'a': 'To book a ride, go to the Rides section from the Home screen, search and select your pickup and dropoff locations, choose your preferred vehicle class (Bike, Auto, or Cab), and tap "Book Ride".'
      },
      {
        'q': 'How do I place a delivery order?',
        'a': 'Navigate to the Delivery section, fill in the pickup and dropoff addresses, describe your package type, specify the estimated weight, review the dynamic price calculation, and click "Place Delivery Order".'
      },
      {
        'q': 'What services are available on RoAdRoBos?',
        'a': 'RoAdRoBos offers comprehensive mobility and vehicle services: ride-hailing (taxi), instant package delivery, professional vehicle servicing (bike and car maintenance), and long-term vehicle rentals.'
      },
    ],
    'Booking & Rides': [
      {
        'q': 'Can I schedule a booking in advance?',
        'a': 'Yes, you can schedule services in advance by going to the specific service page and choosing the "Schedule" option, allowing you to select your preferred date and time slot.'
      },
      {
        'q': 'What is the cancellation policy?',
        'a': 'You can cancel a booking for free before a driver/service provider accepts your request. If cancelled after acceptance, a nominal cancellation fee may apply depending on the time elapsed.'
      },
      {
        'q': 'How is the ride fare determined?',
        'a': 'Ride fares are calculated dynamically using a base fare plus a charge per kilometer of distance and minute of travel duration. Fares may vary depending on traffic conditions and vehicle type.'
      },
    ],
    'Wallet & Billing': [
      {
        'q': 'How do I add money to my wallet?',
        'a': 'Open the Wallet screen, tap the "Topup" button, enter your desired amount, and proceed through our secured payment gateway using UPI, card, or net banking.'
      },
      {
        'q': 'Can I transfer wallet balance to a friend?',
        'a': 'Yes, you can easily transfer funds from your wallet to any other registered user by entering their phone number on the "Transfer" screen.'
      },
      {
        'q': 'Is my payment secure?',
        'a': 'Absolutely. All transactions and card details are encrypted using banking-grade security standards via our integration with secure payment processors.'
      },
    ],
    'Account Security': [
      {
        'q': 'How do I update my profile or password?',
        'a': 'Navigate to Profile > Account Settings. From there, you can update your personal information, manage saved addresses, or safely change your account password.'
      },
      {
        'q': 'How do I set up Emergency SOS?',
        'a': 'Go to Profile > SOS Setup. You can add up to 3 emergency contacts. During a ride or delivery, tapping the SOS icon will immediately share your live location via SMS.'
      },
      {
        'q': 'What should I do if I suspect fraud?',
        'a': 'If you notice any unauthorized transaction or suspicious activity, immediately tap "Contact Support" to chat live with our security response team, or call our emergency hotline.'
      },
    ],
  };

  Future<void> _makeCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: '+919844991225',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _showCategoryFAQ(BuildContext context, String category) {
    final faqs = _faqData[category] ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              // Drag Handle
              const SizedBox(height: 12),
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // FAQ List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: faqs.length,
                  itemBuilder: (context, index) {
                    final faq = faqs[index];
                    return _FAQExpansionTile(question: faq['q']!, answer: faq['a']!);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.bgLightGrey,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: AppColors.textPrimary),
          ),
        ),
        title: const Text(
          'Help Center',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: TextField(
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Iconsax.search_normal_1, size: 20, color: Color(0xFF6366F1)),
                  hintText: 'Search for help...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w500),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.05),
            
            const SizedBox(height: 32),
            const Text(
              'Popular Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildCategoryCard(
                  context,
                  'Getting Started',
                  Iconsax.flash_1,
                  [const Color(0xFFFF7E40), const Color(0xFFFF9E66)],
                  const Color(0xFFFF7E40),
                ),
                _buildCategoryCard(
                  context,
                  'Booking & Rides',
                  Iconsax.car,
                  [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
                  const Color(0xFF1D4ED8),
                ),
                _buildCategoryCard(
                  context,
                  'Wallet & Billing',
                  Iconsax.wallet_3,
                  [const Color(0xFF10B981), const Color(0xFF047857)],
                  const Color(0xFF047857),
                ),
                _buildCategoryCard(
                  context,
                  'Account Security',
                  Iconsax.security_safe,
                  [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
                  const Color(0xFF6D28D9),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            _buildActionCard(
              context,
              'Contact Support',
              'Chat with our team 24/7',
              Iconsax.message_2,
              const Color(0xFF6366F1),
              showPulse: true,
              onTap: () => context.push('/chat'),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              'Call Support',
              'Talk to our representative',
              Iconsax.call,
              const Color(0xFF10B981),
              onTap: _makeCall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String label,
    IconData icon,
    List<Color> gradientColors,
    Color shadowColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCategoryFAQ(context, label),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon backing glow
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(delay: 50.ms);
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
    bool showPulse = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                // Icon wrapper
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (showPulse) ...[
                            // Live Pulsing Dot
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            )
                            .animate(onPlay: (controller) => controller.repeat(reverse: true))
                            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.3, 1.3), duration: 800.ms)
                            .fadeIn(begin: 0.6, duration: 800.ms),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: showPulse ? const Color(0xFF059669) : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: showPulse ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted.withValues(alpha: 0.6)),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }
}

class _FAQExpansionTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQExpansionTile({required this.question, required this.answer});

  @override
  State<_FAQExpansionTile> createState() => _FAQExpansionTileState();
}

class _FAQExpansionTileState extends State<_FAQExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded ? const Color(0xFF6366F1).withValues(alpha: 0.15) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          title: Text(
            widget.question,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _isExpanded ? const Color(0xFF6366F1) : AppColors.textPrimary,
            ),
          ),
          iconColor: const Color(0xFF6366F1),
          collapsedIconColor: AppColors.textSecondary,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
