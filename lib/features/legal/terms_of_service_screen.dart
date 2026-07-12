import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // ── Premium SliverAppBar ────────────────────────────────────────────
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
                    colors: [Color(0xFF0A1628), Color(0xFF1A237E)],
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
                          child: const Icon(Icons.description_rounded,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Terms & Conditions',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900),
                        ),
                        const Text(
                          'Last updated: June 9, 2026',
                          style:
                              TextStyle(color: Color(0xFFB0BEC5), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Table of Contents ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildTOC(),
            ),
          ),

          // ── Main Content ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    number: '1',
                    title: 'Defined Terms',
                    items: const [
                      _Item('1.1',
                          '"SEBCHRIS MOBILITY PVT LTD" (hereinafter referred as the Company). The registered address of the Company is 13 & 14, Horamavu Agara Village, Kalyan Nagar, Babusapalya, Bengaluru -560043.'),
                      _Item('1.2',
                          '"User" shall mean an individual or entity that has accepted the terms and conditions for leasing or renting a Vehicle from the Company.'),
                      _Item('1.3',
                          '"Agreement" means the Service Agreement between the Company and the User.'),
                      _Item('1.4',
                          '"Vehicle" shall mean any motorcycle, motorbike, or scooter (including, but not limited to, petrol or electric models) provided by the Company to a User for leasing or renting pursuant to the terms of this Agreement, for a duration determined between the Company and the User.'),
                      _Item('1.5',
                          '"Conditions" means the General Conditions of Use governing the hiring, leasing, or renting of Vehicles, as amended or modified by the Company from time to time, and includes all applicable terms and conditions.'),
                      _Item('1.6',
                          'These Conditions constitute a legally binding Agreement between the User and the Company, governed by and construed in accordance with the laws of India. The Company reserves the right to modify or update these Conditions at any time. No User is entitled to accept only part of the Conditions. In the event that any User fails to comply with any of the Conditions, the Company reserves the right, at its own discretion, to suspend or withdraw all Services to that User without any notice.'),
                      _Item('1.7',
                          'In this Agreement, the Company and the User shall be collectively referred to as the "Parties" and individually as a "Party".'),
                    ],
                  ),
                  _buildSection(
                    number: '2',
                    title: 'Eligibility & Documentation',
                    items: const [
                      _Item('2.1',
                          'Age: The User must be 18 years old or older to hire a Vehicle.'),
                      _Item('2.2',
                          'Valid Driving Licence: The User must possess a valid driving licence issued by the relevant authorities in India, which is applicable for the class of vehicle being hired.'),
                      _Item('2.3',
                          'Submission of Original Documents: The User shall submit original documents, including but not limited to, a driving licence, identity proof, and address proof, as required by the Company.'),
                      _Item('2.4',
                          'Acceptance of Use Data: The User consents to the Company collecting and using the User\'s personal data.'),
                    ],
                  ),
                  _buildSection(
                    number: '3',
                    title: 'Vehicle Use and Maintenance',
                    items: const [
                      _Item('3.1',
                          'Authorised Vehicle Use: The User is authorized to use only the Vehicle booked in their name and shall not use a Vehicle booked under another User\'s account, and shall not permit any other person to use the Vehicle under their account.'),
                      _Item('3.2',
                          'Vehicle Condition Check: The User confirms having thoroughly inspected the vehicle and being satisfied with its condition, including but not limited to brakes, tires, and other safety features, before entering into this Agreement.'),
                      _Item('3.3',
                          'No Passengers or Loads: The User is not allowed to carry any load or any passenger in the Vehicle.'),
                      _Item('3.4',
                          'Designated Areas: The User shall only use the Vehicle in designated areas specified by the Company and shall not take the Vehicle beyond the designated areas or into prohibited areas.'),
                      _Item('3.5',
                          'Safety and Responsibility: The Company shall not be responsible for the safety of the User. The User is solely responsible for their own safety, the scooter, and others. The User is required to wear a helmet and other safety gear as mandated by law.'),
                      _Item('3.6',
                          'Maintenance: The User agrees to maintain the scooter in good condition throughout the Rental Period — keep it clean, report issues promptly, and return it in the same condition subject to reasonable wear and tear as determined solely by the Company.'),
                      _Item('3.7',
                          'Return of Vehicle: The User agrees to return the Vehicle to the designated location on time and in the same condition as when rented, subject to reasonable wear and tear as determined solely by the Company.'),
                    ],
                  ),
                  _buildSection(
                    number: '4',
                    title: 'Rental Period, Fees, and Charges',
                    items: const [
                      _Item('4.1',
                          'Rental Period: The Rental Period shall commence on the date specified in this Agreement and shall end upon the Scooter\'s return to the Company at its designated location in the same condition, subject to reasonable wear and tear.'),
                      _Item('4.2',
                          'Rental Fees: The User agrees to pay the rental fees as specified by the Company, which includes rental charges, taxes, and any additional fees.'),
                      _Item('4.3',
                          'Late Return: Failure to return the Scooter by the scheduled return time will result in additional fees as fixed by the Company.'),
                      _Item('4.4',
                          'Improper Parking and Traffic Violations: The User shall be responsible for any fines, penalties, or charges resulting from improper parking, traffic violations, or other regulatory infractions.'),
                      _Item('4.5',
                          'Damage, Loss, or Theft: In the event of damage or loss to the Scooter during the Rental Period, the User shall be liable for the full cost of repair or replacement, up to the full value of the vehicle.'),
                      _Item('4.6',
                          'Security Deposit: A Security Deposit is required at the time of Vehicle rental. 50% will be refunded if the Vehicle is returned on time and in the same condition, all fees are paid, and no damages are reported.'),
                      _Item('4.7',
                          'Non-Refundable Payments: All payments made by the User, except for the Security Deposit, are non-refundable, regardless of circumstances.'),
                      _Item('4.8',
                          'Refund Procedure: After fulfilling the Conditions for Security Deposit Refund, 50% of the Security Deposit will be refunded within 2-3 working days through the same payment method used for the rental. A penalty of ₹150/- per day will be charged for refused payments after the due date.'),
                    ],
                  ),
                  _buildProhibitedSection(),
                  _buildSection(
                    number: '6',
                    title: 'Liability',
                    items: const [
                      _Item('6.1',
                          'User Responsibility: The Company is not liable for any injuries, damages, losses, death, or reimbursement claims arising from the User\'s use of the Vehicle. The User is solely responsible for any such incidents.'),
                      _Item('6.2',
                          'Reporting Incidents: In the event of theft, accident, or other incidents, the User must immediately report to the Company and the nearest police station, provide a written complaint, and cooperate fully with the Company.'),
                      _Item('6.3',
                          'Notification of Legal Proceedings: The User agrees to immediately notify the Company of any summons, complaint, or notice related to an accident, theft, or other circumstances involving the Vehicle, and deliver such documents promptly.'),
                    ],
                  ),
                  _buildSection(
                    number: '7',
                    title: 'Termination',
                    items: const [
                      _Item('7.1',
                          'The Company reserves the right to terminate this Agreement immediately if the User breaches any terms or conditions outlined herein. The User acknowledges and agrees that the User does not have the right to terminate this Agreement.'),
                    ],
                  ),
                  _buildSection(
                    number: '8',
                    title: 'Rental Period Extension',
                    items: const [
                      _Item('8.1',
                          'The User may request an extension by notifying the Company in writing or through the designated platform, subject to Company approval and additional charges.'),
                      _Item('8.2',
                          'Prior Intimation: The User must intimate the Company at least 24 hours prior to the end of the original Rental Period. Failure to do so will result in late return fees being applicable immediately.'),
                      _Item('8.3',
                          'Payment for the extended period shall be made upfront and shall be non-refundable.'),
                    ],
                  ),
                  _buildSection(
                    number: '9',
                    title: 'Miscellaneous',
                    items: const [
                      _Item('9.1',
                          'This Agreement constitutes the entire understanding between the Parties and supersedes all prior agreements, whether oral or written.'),
                      _Item('9.2',
                          'This Agreement shall be governed by and construed in accordance with the laws of India. Any disputes arising out of this Agreement shall be subject to the exclusive jurisdiction of the courts of Bangalore.'),
                      _Item('9.3',
                          'If any provision of this Agreement is found to be invalid or unenforceable, the remainder of the Agreement shall remain in full force and effect.'),
                    ],
                  ),
                  _buildAgreementBanner(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTOC() {
    final items = [
      'Defined Terms',
      'Eligibility & Documentation',
      'Vehicle Use and Maintenance',
      'Rental Period, Fees, and Charges',
      'Prohibited Uses',
      'Liability',
      'Termination',
      'Rental Period Extension',
      'Miscellaneous',
    ];
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.list_alt_rounded,
                  color: AppColors.primaryBlue, size: 18),
              SizedBox(width: 8),
              Text('Table of Contents',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepNavy,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('${e.key + 1}',
                          style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w800,
                              fontSize: 11)),
                    ),
                    const SizedBox(width: 10),
                    Text(e.value,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String number,
    required String title,
    required List<_Item> items,
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
                      color: AppColors.deepNavy,
                      borderRadius: BorderRadius.circular(8)),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(item.clause,
                                  style: const TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(item.text,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                        height: 1.6))),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProhibitedSection() {
    const prohibitions = [
      'Use the scooter for racing or reckless driving.',
      'Drive the scooter off-road.',
      'Use the scooter for carrying passengers or goods for hire.',
      'Transport hazardous materials.',
      'Operate the scooter under the influence of alcohol, drugs, or medicine.',
      'Engage in any criminal or illegal activities.',
      'Use the scooter in an imprudent, negligent, or abusive manner.',
      'Use the scooter for abnormal or unauthorized purposes.',
      'Use a mobile phone or any other electronic device while operating the scooter.',
      'Transport flammable, poisonous, or other hazardous substances.',
      'Carry objects that may cause damage to the vehicle.',
      'Use the scooter in any manner deemed unreasonable, inappropriate, or unsafe.',
    ];

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3E0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: const Color(0xFFF57C00),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text('5',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12)),
                ),
                const SizedBox(width: 12),
                const Text('Prohibited Uses',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFF57C00),
                        fontSize: 15)),
                const Spacer(),
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFF57C00), size: 18),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'The User shall NOT engage in the following:',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.5),
                ),
                const SizedBox(height: 12),
                ...prohibitions.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                                color: Color(0xFFF57C00),
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(p,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                      height: 1.5))),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1628), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.handshake_rounded, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          const Text(
            'Agreement Acknowledgement',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'By renting a scooter from the Company, the User acknowledges that the User has read, understood, and agreed to be bound by these Terms and Conditions.',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
                height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Item {
  final String clause;
  final String text;
  const _Item(this.clause, this.text);
}
