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
    {'name': 'High-Grade Engine Oil', 'category': 'Fluids', 'price': '₹1,200', 'stock': 15, 'icon': Icons.oil_barrel_rounded},
    {'name': 'Top-Grade Brake Pads', 'category': 'Brakes', 'price': '₹2,450', 'stock': 8, 'icon': Icons.settings_input_component_rounded},
    {'name': 'Ultra-Performance Spark Plug', 'category': 'Engine', 'price': '₹450', 'stock': 42, 'icon': Icons.bolt_rounded},
    {'name': 'High-Efficiency Air Filter', 'category': 'Filters', 'price': '₹380', 'stock': 20, 'icon': Icons.air_rounded},
    {'name': 'Gold-Standard Battery', 'category': 'Electrical', 'price': '₹4,800', 'stock': 5, 'icon': Icons.battery_charging_full_rounded},
    {'name': 'Wiper Blades', 'category': 'Accessories', 'price': '₹650', 'stock': 12, 'icon': Icons.waves_rounded},
  ];

  String _searchQuery = '';
  String _selectedCategory = 'All';

  void _onBottomNavTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _bottomNavIndex = index);
    switch (index) {
      case 0: context.go('/tech-dashboard'); break;
      case 1: context.go('/tech-tasks'); break;
      case 2: break; // Already on parts
      case 3: context.go('/tech-profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredParts = _parts.where((p) {
      final matchesSearch = p['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat = _selectedCategory == 'All' || p['category'] == _selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Parts Catalogue', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.bgLightGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      icon: Icon(Iconsax.search_normal, size: 20, color: AppColors.textSecondary),
                      hintText: 'Search parts...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 14, color: AppColors.textMuted),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Categories
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['All', 'Fluids', 'Brakes', 'Engine', 'Filters', 'Electrical', 'Accessories'].map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.textPrimary)),
                          selected: isSelected,
                          onSelected: (val) => setState(() => _selectedCategory = cat),
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: Colors.white,
                          side: BorderSide(color: isSelected ? AppColors.primaryBlue : AppColors.border),
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
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
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
    
    ref.read(technicianProvider.notifier).addSparePart(part);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${part.name} added to job!'),
        backgroundColor: AppColors.primaryBlue,
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
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
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

  Widget _navItem(BuildContext context, IconData icon, String label, int index) {
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
              child: Icon(icon, color: isActive ? const Color(0xFF1A237E) : Colors.grey, size: 24),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? const Color(0xFF1A237E) : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildPartCard(Map<String, dynamic> part) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _addPartToJob(part);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(12)),
              child: Icon(part['icon'] as IconData, color: AppColors.primaryBlue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(part['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(part['category'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(part['price'] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('${part['stock']} in stock', style: TextStyle(color: (part['stock'] as int) < 10 ? AppColors.dangerRed : AppColors.successGreen, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.05, end: 0),
    );
  }
}

