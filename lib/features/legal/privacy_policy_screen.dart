import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // ── Premium SliverAppBar ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.deepNavy,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A1628), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.privacy_tip_rounded,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Privacy Policy',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900),
                        ),
                        const Text(
                          'Last updated: June 9, 2026',
                          style:
                              TextStyle(color: Color(0xFF90CAF9), fontSize: 12),
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompanyCard(),
                  const SizedBox(height: 20),
                  _buildSection(
                    number: '1',
                    title: 'Introduction',
                    content:
                        'SebChris Mobility Pvt Ltd. ("RoAd RoBo\'s", "we", "us", "our") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our website, mobile application, and bike rental services (collectively, the "Services").',
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
                          'Financial information, such as data related to your payment method (e.g., valid credit card number, card brand, expiration date) that we may collect when you make a purchase. We store only very limited, if any, financial information. Otherwise, all financial information is stored by our payment processor.'),
                      _Bullet('Derivative Data',
                          'Information our servers automatically collect when you access the Services, such as your IP address, your browser type, your operating system, your access times, and the pages you have viewed directly before and after accessing the Services.'),
                      _Bullet('Mobile Device Data',
                          'Device information such as your mobile device ID, model, and manufacturer, and information about the location of your device, if you access the Services from a mobile device.'),
                    ],
                  ),
                  _buildSection(
                    number: '3',
                    title: 'Use of Your Information',
                    content:
                        'Having accurate information about you permits us to provide you with a smooth, efficient, and customized experience. Specifically, we may use information collected about you via the Services to:',
                    listItems: [
                      'Create and manage your account.',
                      'Process your bookings and payments.',
                      'Email you regarding your account or order.',
                      'Enable user-to-user communications.',
                      'Monitor and analyze usage and trends to improve your experience with the Services.',
                      'Notify you of updates to the Services.',
                      'Prevent fraudulent transactions, monitor against theft, and protect against criminal activity.',
                      'Request feedback and contact you about your use of the Services.',
                      'Resolve disputes and troubleshoot problems.',
                    ],
                  ),
                  _buildSection(
                    number: '4',
                    title: 'Disclosure of Your Information',
                    content:
                        'We may share information we have collected about you in certain situations. Your information may be disclosed as follows:',
                    bullets: const [
                      _Bullet('By Law or to Protect Rights',
                          'If we believe the release of information about you is necessary to respond to legal process, to investigate or remedy potential violations of our policies, or to protect the rights, property, and safety of others, we may share your information as permitted or required by any applicable law, rule, or regulation.'),
                      _Bullet('Third-Party Service Providers',
                          'We may share your information with third parties that perform services for us or on our behalf, including payment processing, data analysis, email delivery, hosting services, customer service, and marketing assistance.'),
                    ],
                  ),
                  _buildSection(
                    number: '5',
                    title: 'Security of Your Information',
                    content:
                        'We use administrative, technical, and physical security measures to help protect your personal information. While we have taken reasonable steps to secure the personal information you provide to us, please be aware that despite our efforts, no security measures are perfect or impenetrable, and no method of data transmission can be guaranteed against any interception or other type of misuse.',
                  ),
                  _buildSection(
                    number: '6',
                    title: 'Contact Us',
                    content:
                        'If you have questions or comments about this Privacy Policy, please contact us at:',
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withValues(alpha: 0.08),
            AppColors.primaryBlue.withValues(alpha: 0.03)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shield_rounded,
                color: AppColors.primaryBlue, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RoAd RoBo\'s',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.deepNavy,
                        fontSize: 15)),
                Text('SebChris Mobility Pvt Ltd. — Your data is safe with us.',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.4)),
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.deepNavy.withValues(alpha: 0.04),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(number,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12)),
                ),
                const SizedBox(width: 12),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepNavy,
                        fontSize: 15)),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(content,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.6)),
                if (bullets != null) ...bullets.map((b) => _buildBulletItem(b)),
                if (listItems != null) ...[
                  const SizedBox(height: 8),
                  ...listItems.map((item) => Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 7),
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(item,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                        height: 1.5))),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(10),
        border: const Border(
            left: BorderSide(color: AppColors.primaryBlue, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(b.title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepNavy,
                  fontSize: 13)),
          const SizedBox(height: 4),
          Text(b.description,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded,
                  color: AppColors.primaryBlue, size: 18),
              SizedBox(width: 8),
              Text('SebChris Mobility Pvt. Ltd.',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepNavy,
                      fontSize: 14)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '13 & 14, Horamavu Agara Village,\nK.R. Puram Hobli, Kalyan Nagar Post,\nBengaluru - 560043',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 13, height: 1.6),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.email_outlined,
                  color: AppColors.primaryBlue, size: 16),
              SizedBox(width: 8),
              Text('privacy@roadrobos.com',
                  style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
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
