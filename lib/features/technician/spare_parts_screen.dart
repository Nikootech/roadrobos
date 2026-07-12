import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import 'technician_provider.dart';

class SparePartsScreen extends ConsumerStatefulWidget {
  const SparePartsScreen({super.key});

  @override
  ConsumerState<SparePartsScreen> createState() => _SparePartsScreenState();
}

class _SparePartsScreenState extends ConsumerState<SparePartsScreen> {
  int _bottomNavIndex = 2; // Default to Parts tab
  final List<Map<String, dynamic>> _parts = [
    {
      'name': 'High-Grade Engine Oil',
      'category': 'Fluids',
      'price': '₹1,200',
      'stock': 15,
      'icon': Icons.oil_barrel_rounded
    },
    {
      'name': 'Top-Grade Brake Pads',
      'category': 'Brakes',
      'price': '₹2,450',
      'stock': 8,
      'icon': Icons.settings_input_component_rounded
    },
    {
      'name': 'Ultra-Performance Spark Plug',
      'category': 'Engine',
      'price': '₹450',
      'stock': 42,
      'icon': Icons.bolt_rounded
    },
    {
      'name': 'High-Efficiency Air Filter',
      'category': 'Filters',
      'price': '₹380',
      'stock': 20,
      'icon': Icons.air_rounded
    },
    {
      'name': 'Gold-Standard Battery',
      'category': 'Electrical',
      'price': '₹4,800',
      'stock': 5,
      'icon': Icons.battery_charging_full_rounded
    },
    {
      'name': 'Wiper Blades',
      'category': 'Accessories',
      'price': '₹650',
      'stock': 12,
      'icon': Icons.waves_rounded
    },
  ];

  String _searchQuery = '';
  String _selectedCategory = 'All';

  void _onBottomNavTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _bottomNavIndex = index);
    switch (index) {
      case 0:
        context.go('/tech-dashboard');
        break;
      case 1:
        context.go('/tech-tasks');
        break;
      case 2:
        break; // Already on parts
      case 3:
        context.go('/tech-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredParts = _parts.where((p) {
      final matchesSearch =
          p['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat =
          _selectedCategory == 'All' || p['category'] == _selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Color(0xFF1A237E)),
          onPressed: () => context.pop(),
        ),
        title: const Text('Parts Catalogue',
            style: TextStyle(
                color: Color(0xFF1A237E),
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F2F4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A237E)),
                    decoration: const InputDecoration(
                      icon: Icon(Iconsax.search_normal,
                          size: 18, color: Color(0xFF1A237E)),
                      hintText: 'Search Spare Parts...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Categories
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      'All',
                      'Fluids',
                      'Brakes',
                      'Engine',
                      'Filters',
                      'Electrical',
                      'Accessories'
                    ].map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedCategory = cat);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1A237E)
                                  : const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF1A237E)
                                      : const Color(0xFFE5E9F0)),
                            ),
                            child: Center(
                              child: Text(cat,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[600],
                                  )),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: 100),
              itemCount: filteredParts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final part = filteredParts[index];
                return _buildPartCard(part);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  void _addPartToJob(Map<String, dynamic> partData) {
    final part = SparePart(
      name: partData['name'] as String,
      qty: '1 Unit',
    );

    final TechnicianJob? currentJob = ref.read(selectedJobProvider);
    if (currentJob == null) return;

    ref.read(technicianProvider.notifier).addSparePart(currentJob.id, part);

    // Legacy telemetry removed — Firestore handles spare part additions now

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${part.name} added to job!'),
        backgroundColor: const Color(0xFF1A237E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F2F4))),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, Iconsax.home5, 'Dashboard', 0),
          _navItem(context, Iconsax.task_square5, 'Jobs', 1),
          _navItem(context, Iconsax.box, 'Parts', 2),
          _navItem(context, Iconsax.user, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _navItem(
      BuildContext context, IconData icon, String label, int index) {
    final isActive = _bottomNavIndex == index;
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFE8EAF6) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: isActive ? const Color(0xFF1A237E) : Colors.grey,
                  size: 24),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? const Color(0xFF1A237E) : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildPartCard(Map<String, dynamic> part) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        _addPartToJob(part);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8EAF6)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A237E).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1A237E).withValues(alpha: 0.1),
                    const Color(0xFF3949AB).withValues(alpha: 0.05)
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(part['icon'] as IconData,
                  color: const Color(0xFF1A237E), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(part['name'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: Color(0xFF1A237E))),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F2F4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(part['category'] as String,
                        style: const TextStyle(
                            color: Color(0xFF5E6AD2),
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(part['price'] as String,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A237E),
                        fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: (part['stock'] as int) < 10
                            ? Colors.red
                            : Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('${part['stock']} IN STOCK',
                        style: TextStyle(
                          color: (part['stock'] as int) < 10
                              ? Colors.red
                              : Colors.green,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        )),
                  ],
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: 50.ms).slideX(begin: 0.05, end: 0),
    );
  }
}
