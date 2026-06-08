import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Active', 'Maintenance', 'Inactive'];

  final List<Map<String, dynamic>> _mockAssets = [
    {
      'title': 'Company Car - 04',
      'id': 'ID: VHC-8371',
      'status': 'Active',
      'icon': Icons.directions_car_rounded,
    },
    {
      'title': 'Central Office Battery Pack',
      'id': 'ID: BAT-1024',
      'status': 'Maintenance',
      'icon': Icons.battery_charging_full_rounded,
    },
    {
      'title': 'Warehouse Forklift',
      'id': 'ID: EQ-5150',
      'status': 'Active',
      'icon': Icons.fork_left_rounded, // or forklift icon
    },
    {
      'title': 'Delivery Van',
      'id': 'ID: VHC-2112',
      'status': 'Inactive',
      'icon': Icons.local_shipping_rounded,
    },
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF10B981); // Emerald Green
      case 'Maintenance':
        return const Color(0xFFF59E0B); // Amber
      case 'Inactive':
        return const Color(0xFFEF4444); // Red
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine background color similar to the image (off-white/light grey)
    const bgColor = Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.black, size: 28),
          onPressed: () {
            // Check if we can pop, otherwise just log or do nothing.
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981), // Match the green plus button
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'Assets',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),
              
              // Search Bar
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(Icons.search_rounded, color: Color(0xFF6B7280), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by name, ID...',
                          hintStyle: GoogleFonts.inter(
                            color: const Color(0xFF6B7280),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFD1FAE5) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          filter,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? const Color(0xFF065F46) : const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              
              // Asset List
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _mockAssets.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final asset = _mockAssets[index];
                    final statusColor = _getStatusColor(asset['status']);
                    
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          // Left Icon Box
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              asset['icon'],
                              color: Colors.black87,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Details Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  asset['title'],
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  asset['id'],
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      asset['status'],
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Right Chevron
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF9CA3AF),
                            size: 24,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
