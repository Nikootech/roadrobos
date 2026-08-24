import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../shared/widgets/kinetic_motion.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // ── Executive Hero Header ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: Center(
              child: ScaleOnTap(
                onTap: () => context.pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF006241)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF006241)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Iconsax.shield_tick,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Privacy Policy',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Last updated: June 9, 2026 • Legal & Compliance',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompanyCard(),
                  const SizedBox(height: 20),
                  _buildSection(
                    number: '1',
                    title: 'Introduction',
                    content:
                        'SebChris Mobility Pvt Ltd. ("RoAd RoBo\'s", "we", "us", "our") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our website, mobile application, ride-hailing and vehicle rental services (collectively, the "Services").',
                  ),
                  _buildSection(
                    number: '2',
                    title: 'Information We Collect',
                    content:
                        'We may collect information about you in a variety of ways. The information we may collect via the Services includes:',
                    bullets: const [
                      _Bullet('Personal Data',
                          'Personally identifiable information, such as your name, email address, phone number, and demographic information, that you voluntarily give to us when you register or make a booking.'),
                      _Bullet('Financial Data',
                          'Financial information, such as data related to your payment method (e.g., valid credit card number, card brand, expiration date) that we may collect when you make a purchase. All payments are encrypted and processed by PCI-DSS compliant gateways.'),
                      _Bullet('Derivative Data',
                          'Information our servers automatically collect when you access the Services, such as your IP address, your browser type, your operating system, your access times, and diagnostic crash logs.'),
                      _Bullet('Mobile Device & Location Data',
                          'Device model, manufacturer, and high-precision GPS coordinates during active rides and dispatch services for passenger safety.'),
                    ],
                  ),
                  _buildSection(
                    number: '3',
                    title: 'Use of Your Information',
                    content:
                        'Having accurate information permits us to provide a seamless and secure experience. Specifically, we may use your information to:',
                    listItems: [
                      'Create and manage your verified user account.',
                      'Process your ride bookings, service appointments and payments.',
                      'Send real-time driver ETA alerts and SMS dispatch notifications.',
                      'Enable user-to-driver in-app messaging and VoIP calls.',
                      'Monitor and analyze system metrics to prevent fraud and protect user safety.',
                      'Resolve billing queries and support tickets efficiently.',
                    ],
                  ),
                  _buildSection(
                    number: '4',
                    title: 'Disclosure of Your Information',
                    content:
                        'We do not sell your personal information. Your data may be disclosed in limited scenarios as follows:',
                    bullets: const [
                      _Bullet('By Law or to Protect Rights',
                          'If required by applicable law, court subpoenas, or emergency regulatory inquiries to protect passenger and driver safety.'),
                      _Bullet('Verified Service Providers',
                          'Payment processors, SMS gateways, and cloud infrastructure partners that adhere to strict data security standards.'),
                    ],
                  ),
                  _buildSection(
                    number: '5',
                    title: 'Security of Your Information',
                    content:
                        'We utilize enterprise-grade AES-256 encryption, SSL/TLS pinning, and hardware-backed Android KeyStore protection. While no digital system is 100% immune, we apply continuous vulnerability auditing to keep your personal data secure.',
                  ),
                  _buildSection(
                    number: '6',
                    title: 'Contact Us',
                    content:
                        'If you have questions, feedback, or data privacy requests regarding this policy, please reach out to our Data Protection Officer:',
                  ),
                  _buildContactCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF006241).withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006241).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF006241), Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(Iconsax.shield_tick, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RoAd RoBo\'s Privacy Shield',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'SebChris Mobility Pvt Ltd. — 100% Encrypted & Safe',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String number,
    required String title,
    required String content,
    List<_Bullet>? bullets,
    List<String>? listItems,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF006241), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    number,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    fontSize: 15,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF475569),
                    fontSize: 13.5,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (bullets != null) ...bullets.map((b) => _buildBulletItem(b)),
                if (listItems != null) ...[
                  const SizedBox(height: 12),
                  ...listItems.map((item) => Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF006241),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF475569),
                                  fontSize: 13,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletItem(_Bullet b) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.tick_circle,
                  color: Color(0xFF006241), size: 14),
              const SizedBox(width: 6),
              Text(
                b.title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            b.description,
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 12.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.location, color: Color(0xFF006241), size: 18),
              const SizedBox(width: 8),
              Text(
                'SebChris Mobility Pvt. Ltd.',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '13 & 14, Horamavu Agara Village,\nK.R. Puram Hobli, Kalyan Nagar Post,\nBengaluru - 560043',
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 13,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Iconsax.sms, color: Color(0xFF006241), size: 16),
              const SizedBox(width: 8),
              Text(
                'privacy@roadrobos.com',
                style: GoogleFonts.inter(
                  color: const Color(0xFF006241),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bullet {
  final String title;
  final String description;
  const _Bullet(this.title, this.description);
}
