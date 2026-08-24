import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconsax/iconsax.dart';
import '../../shared/widgets/kinetic_motion.dart';
import '../../shared/widgets/sos_button.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const Map<String, List<Map<String, String>>> _faqData = {
    'Getting Started': [
      {
        'q': 'How do I book a ride?',
        'a':
            'To book a ride, go to the Rides section from the Home screen, search and select your pickup and dropoff locations, choose your preferred vehicle class (Bike, Auto, or Cab), and tap "Book Ride".'
      },
      {
        'q': 'How do I place a delivery order?',
        'a':
            'Navigate to the Delivery section, fill in the pickup and dropoff addresses, describe your package type, specify the estimated weight, review the dynamic price calculation, and click "Place Delivery Order".'
      },
      {
        'q': 'What services are available on RoAdRoBos?',
        'a':
            'RoAdRoBos offers comprehensive mobility and vehicle services: ride-hailing (taxi), instant package delivery, professional vehicle servicing (bike and car maintenance), and long-term vehicle rentals.'
      },
    ],
    'Booking & Rides': [
      {
        'q': 'Can I schedule a booking in advance?',
        'a':
            'Yes, you can schedule services in advance by going to the specific service page and choosing the "Schedule" option, allowing you to select your preferred date and time slot.'
      },
      {
        'q': 'What is the cancellation policy?',
        'a':
            'You can cancel a booking for free before a driver/service provider accepts your request. If cancelled after acceptance, a nominal cancellation fee may apply depending on the time elapsed.'
      },
      {
        'q': 'How is the ride fare determined?',
        'a':
            'Ride fares are calculated dynamically using a base fare plus a charge per kilometer of distance and minute of travel duration. Fares may vary depending on traffic conditions and vehicle type.'
      },
    ],
    'Wallet & Billing': [
      {
        'q': 'How do I add money to my wallet?',
        'a':
            'Open the Wallet screen, tap the "Topup" button, enter your desired amount, and proceed through our secured payment gateway using UPI, card, or net banking.'
      },
      {
        'q': 'Can I transfer wallet balance to a friend?',
        'a':
            'Yes, you can easily transfer funds from your wallet to any other registered user by entering their phone number on the "Transfer" screen.'
      },
      {
        'q': 'Is my payment secure?',
        'a':
            'Absolutely. All transactions and card details are encrypted using banking-grade security standards via our integration with secure payment processors.'
      },
    ],
    'Account Security': [
      {
        'q': 'How do I update my profile or password?',
        'a':
            'Navigate to Profile > Account Settings. From there, you can update your personal information, manage saved addresses, or safely change your account password.'
      },
      {
        'q': 'How do I set up Emergency SOS?',
        'a':
            'Go to Profile > SOS Setup. You can add up to 3 emergency contacts. During a ride or delivery, tapping the SOS icon will immediately share your live location via SMS.'
      },
      {
        'q': 'What should I do if I suspect fraud?',
        'a':
            'If you notice any unauthorized transaction or suspicious activity, immediately tap "Contact Support" to chat live with our security response team, or call our emergency hotline.'
      },
    ],
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 24,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 14),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: faqs.length,
                  itemBuilder: (context, index) {
                    final faq = faqs[index];
                    return _FAQExpansionTile(
                      question: faq['q']!,
                      answer: faq['a']!,
                    );
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
        scrolledUnderElevation: 0,
        leading: Center(
          child: ScaleOnTap(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Color(0xFF0F172A)),
            ),
          ),
        ),
        title: Text(
          'Help Center',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: SOSButton.headerPill(
              rideDetails: 'Help Center Safety Support',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: 'Search topics, rides, payments...',
                  hintStyle: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: const Icon(Iconsax.search_normal_1,
                      color: Color(0xFF006241), size: 18),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              size: 18, color: Color(0xFF64748B)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Section Header
            Text(
              'Popular Categories',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16),

            // 4 React-Style Category Tiles (ZERO PURPLE)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.15,
              children: [
                _buildCategoryCard(
                  context,
                  'Getting Started',
                  Iconsax.flash_1,
                  [const Color(0xFFEA580C), const Color(0xFFFB923C)],
                ),
                _buildCategoryCard(
                  context,
                  'Booking & Rides',
                  Iconsax.car,
                  [const Color(0xFF0284C7), const Color(0xFF38BDF8)],
                ),
                _buildCategoryCard(
                  context,
                  'Wallet & Billing',
                  Iconsax.wallet_3,
                  [const Color(0xFF006241), const Color(0xFF10B981)],
                ),
                _buildCategoryCard(
                  context,
                  'Account Security',
                  Iconsax.shield_tick,
                  [const Color(0xFF0F172A), const Color(0xFF334155)],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Direct Support Actions
            Text(
              'Direct Support',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),

            // Emergency SOS Action (Karnataka 112)
            _buildActionCard(
              context,
              'Emergency SOS (112)',
              'Namma 112 • Karnataka Safety Hub',
              Iconsax.shield_security,
              const Color(0xFFE11D48),
              showPulse: true,
              pulseColor: const Color(0xFFE11D48),
              onTap: () {
                KarnatakaSafetyHubModal.show(
                  context,
                  rideDetails: 'Help Center Safety Escalation',
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              'Contact Support',
              'Chat with our team 24/7',
              Iconsax.messages_3,
              const Color(0xFF006241),
              showPulse: true,
              onTap: () => context.push('/chat'),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              'Call Support',
              'Talk to our live representative',
              Iconsax.call,
              const Color(0xFF0284C7),
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
  ) {
    return ScaleOnTap(
      onTap: () => _showCategoryFAQ(context, label),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
    bool showPulse = false,
    Color pulseColor = const Color(0xFF10B981),
  }) {
    return ScaleOnTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
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
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (showPulse) ...[
                        PulseBeacon(
                          color: pulseColor,
                          size: 7,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

class _FAQExpansionTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQExpansionTile({
    required this.question,
    required this.answer,
  });

  @override
  State<_FAQExpansionTile> createState() => _FAQExpansionTileState();
}

class _FAQExpansionTileState extends State<_FAQExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _isExpanded ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isExpanded
              ? const Color(0xFF006241).withValues(alpha: 0.4)
              : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            widget.question,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF475569),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
