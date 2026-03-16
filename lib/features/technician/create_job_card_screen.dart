import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

class CreateJobCardScreen extends StatefulWidget {
  const CreateJobCardScreen({super.key});

  @override
  State<CreateJobCardScreen> createState() => _CreateJobCardScreenState();
}

class _CreateJobCardScreenState extends State<CreateJobCardScreen> {
  final List<Map<String, dynamic>> _scopeItems = [
    {'title': 'Oil Change - Synthetic', 'price': '₹1,500.00', 'duration': '0.5h', 'icon': Iconsax.drop},
    {'title': 'Brake Pad Replacement', 'price': '₹2,450.00', 'duration': '1.5h', 'icon': Iconsax.setting_2},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ),
        title: const Text(
          'Create Job Card', 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Save', style: TextStyle(color: Color(0xFF5E81AC), fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // 1. Vehicle Context
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/scorpio.png', // Fallback
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('VEHICLE CONTEXT', style: TextStyle(color: Color(0xFF5E81AC), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            const Text('2021 Toyota Rav4', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.directions_car_rounded, size: 14, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text('XYZ-123', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4C566A))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                // 2. Assign Technician
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Assign Technician', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E9F0)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Iconsax.user_octagon, color: Colors.grey),
                            SizedBox(width: 12),
                            Text('Select a technician', style: TextStyle(color: Colors.grey)),
                            Spacer(),
                            Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                // 3. Mileage & Completion
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSmallCard(
                          title: 'Current Mileage',
                          child: const Row(
                            children: [
                              Text('0', style: TextStyle(fontSize: 18, color: Colors.grey)),
                              Spacer(),
                              Text('km', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSmallCard(
                          title: 'Est. Completion',
                          child: const Text('mm/dd/yyyy, -', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                // 4. Scope of Work
                _buildCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Iconsax.setting_2, size: 18, color: Color(0xFF5E81AC)),
                            SizedBox(width: 12),
                            Text('Scope of Work', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ..._scopeItems.map((item) => _buildScopeItem(item)),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF5E81AC).withValues(alpha: 0.3)),
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, color: Color(0xFF5E81AC), size: 18),
                                SizedBox(width: 8),
                                Text('Add Service Item', style: TextStyle(color: Color(0xFF5E81AC), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                // 5. Pre-Service Photos
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Iconsax.camera, size: 18, color: Color(0xFF5E81AC)),
                              SizedBox(width: 12),
                              Text('Pre-Service Photos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2F6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('2 Added', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4C566A))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildAddPhoto(),
                            const SizedBox(width: 12),
                            _buildPhotoThumb('assets/images/nexon.png'),
                            const SizedBox(width: 12),
                            _buildPhotoThumb('assets/images/creta.png'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // Fixed Bottom Button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E5E5E),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Generate Job Card', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: child,
    );
  }

  Widget _buildSmallCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E9F0)),
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildScopeItem(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEF2F6))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item['icon'] as IconData, color: const Color(0xFF5E81AC), size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('${item['price']} • ${item['duration']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.remove_circle_outline, color: Colors.grey.withValues(alpha: 0.5), size: 20),
        ],
      ),
    );
  }

  Widget _buildAddPhoto() {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F0), width: 2),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.camera, color: Colors.grey),
          SizedBox(height: 8),
          Text('ADD NEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPhotoThumb(String asset) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(asset, width: 100, height: 100, fit: BoxFit.cover),
    );
  }
}

