import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

class SparePartsScreen extends StatefulWidget {
  const SparePartsScreen({super.key});

  @override
  State<SparePartsScreen> createState() => _SparePartsScreenState();
}

class _SparePartsScreenState extends State<SparePartsScreen> {
  final List<Map<String, dynamic>> _parts = [
    {'name': 'Castrol Engine Oil 5W-30', 'category': 'Fluids', 'price': '₹1,200', 'stock': 15, 'icon': Icons.oil_barrel_rounded},
    {'name': 'Bosch Brake Pads (Set)', 'category': 'Brakes', 'price': '₹2,450', 'stock': 8, 'icon': Icons.settings_input_component_rounded},
    {'name': 'NGK Spark Plug', 'category': 'Engine', 'price': '₹450', 'stock': 42, 'icon': Icons.bolt_rounded},
    {'name': 'Purolator Air Filter', 'category': 'Filters', 'price': '₹380', 'stock': 20, 'icon': Icons.air_rounded},
    {'name': 'Exide Battery 35Ah', 'category': 'Electrical', 'price': '₹4,800', 'stock': 5, 'icon': Icons.battery_charging_full_rounded},
    {'name': 'Wiper Blades (Pair)', 'category': 'Exterior', 'price': '₹650', 'stock': 12, 'icon': Icons.waves_rounded},
  ];

  String _searchQuery = '';
  String _selectedCategory = 'All';

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
                    children: ['All', 'Fluids', 'Brakes', 'Engine', 'Filters', 'Electrical', 'Exterior'].map((cat) {
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
              padding: const EdgeInsets.all(16),
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
    );
  }

  Widget _buildPartCard(Map<String, dynamic> part) {
    return Container(
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
    ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.05, end: 0);
  }
}

