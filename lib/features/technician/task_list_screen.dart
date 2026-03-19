import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// import '../profile/user_provider.dart'; // Removed unused import
import 'technician_provider.dart';

/// Technician Task List matching Figma Screen [86] & [78]
class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  String _selectedFilter = 'All Jobs';
  int _bottomNavIndex = 1; // Default to Jobs tab

  // Mock job data for filtering
  final List<Map<String, String>> _allJobs = [
    {
      'priority': 'HIGH PRIORITY',
      'time': '10:00 AM',
      'vehicle': 'Hyundai Creta SX',
      'plate': 'MH 12 AB 1234',
      'task': '10,000km Service + Oil Change',
      'description': 'Includes filter replacement and fluid top-up.',
      'status': 'In-Progress',
      'image': 'assets/images/creta.png'
    },
    {
      'priority': 'STANDARD',
      'time': '01:30 PM',
      'vehicle': 'Maruti Swift Dzire',
      'plate': 'KA 05 MJ 8899',
      'task': 'Brake Pad Replacement',
      'description': 'Front and rear wheels. Check rotors.',
      'status': 'To-Do',
      'image': 'assets/images/dzire.png'
    },
    {
      'priority': 'STANDARD',
      'time': '03:00 PM',
      'vehicle': 'Honda City ZX',
      'plate': 'DL 09 CA 5566',
      'task': 'AC Compressor Service',
      'description': 'Check refrigerant levels and clean filters.',
      'status': 'Done',
      'image': 'assets/images/city.png'
    },
  ];

  List<Map<String, String>> get _filteredJobs {
    if (_selectedFilter == 'All Jobs') return _allJobs;
    if (_selectedFilter == 'High Priority') return _allJobs.where((j) => j['priority'] == 'HIGH PRIORITY').toList();
    if (_selectedFilter == 'In-Progress') return _allJobs.where((j) => j['status'] == 'In-Progress').toList();
    if (_selectedFilter == 'Completed') return _allJobs.where((j) => j['status'] == 'Done').toList();
    return _allJobs;
  }

  void _onBottomNavTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _bottomNavIndex = index);
    switch (index) {
      case 0: context.go('/tech-dashboard'); break;
      case 1: break; // Already on tasks
      case 2: context.go('/tech-spare-parts'); break;
      case 3: context.go('/tech-profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final userState = ref.watch(userProvider); // Removed unused variable
    final activeJob = ref.watch(technicianProvider);
    final today = DateFormat('EEEE, d MMM').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(today, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      const Text('Service Tasks', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1A237E))),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/notifications');
                    },
                    child: _buildNotificationBadge(),
                  ),
                ],
              ),
            ),

            // 2. Summary Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _buildSummaryCard('ASSIGNED', '${_allJobs.length + (activeJob != null ? 1 : 0)}', Iconsax.box, const Color(0xFF5E6AD2))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSummaryCard('PENDING', '${_allJobs.where((j) => j['status'] == 'To-Do' || j['status'] == 'In-Progress').length}', Iconsax.timer_1, const Color(0xFFFF9F43))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSummaryCard('DONE', '${_allJobs.where((j) => j['status'] == 'Done').length + (activeJob?.status == 'COMPLETED' ? 1 : 0)}', Iconsax.tick_circle, const Color(0xFF28C76F))),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. Interactive Filter Chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: ['All Jobs', 'High Priority', 'In-Progress', 'Completed'].map((label) {
                  return _buildFilterChip(label, _selectedFilter == label);
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // 4. Job List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  if (activeJob != null &&
                      (_selectedFilter == 'All Jobs' ||
                          (_selectedFilter == 'In-Progress' && activeJob.status == 'IN PROGRESS') ||
                          (_selectedFilter == 'Completed' && activeJob.status == 'COMPLETED')))
                    _buildJobCard(
                      context: context,
                      ref: ref,
                      priority: 'ACTIVE JOB',
                      time: activeJob.estimatedCompletion,
                      vehicle: '2021 Toyota Rav4',
                      plate: 'XYZ-123',
                      task: activeJob.checklist.isEmpty ? 'General Service' : activeJob.checklist.first.task,
                      description: 'Active job managed via provider.',
                      status: activeJob.status == 'IN PROGRESS' ? 'In-Progress' : (activeJob.status == 'COMPLETED' ? 'Done' : 'To-Do'),
                      image: null,
                    ),
                  if (activeJob != null) const SizedBox(height: 16),
                  ..._filteredJobs.map((job) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildJobCard(
                          context: context,
                          ref: ref,
                          priority: job['priority']!,
                          time: job['time']!,
                          vehicle: job['vehicle']!,
                          plate: job['plate']!,
                          task: job['task']!,
                          description: job['description']!,
                          status: job['status']!,
                          image: job['image'],
                        ),
                      )),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tech-create-job'),
        backgroundColor: const Color(0xFF1A237E),
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNotificationBadge() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Stack(
        children: [
          const Icon(Iconsax.notification, color: Color(0xFF1A237E), size: 22),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 0.5)),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1A237E))),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A237E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF1A237E) : const Color(0xFFE5E9F0)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard({
    required BuildContext context,
    required WidgetRef ref,
    required String priority,
    required String time,
    required String vehicle,
    required String plate,
    required String task,
    required String description,
    required String status,
    String? image,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E9F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: priority == 'HIGH PRIORITY' || priority == 'ACTIVE JOB' ? const Color(0xFFFFEBEE) : const Color(0xFFF1F2F4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            priority,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: priority == 'HIGH PRIORITY' || priority == 'ACTIVE JOB' ? Colors.red : Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time_filled, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: image != null
                          ? Image.asset(image, width: 44, height: 44, fit: BoxFit.cover)
                          : Container(width: 44, height: 44, color: Colors.grey[200], child: const Icon(Icons.car_repair, size: 20, color: Colors.grey)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(vehicle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A237E))),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9C4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(plate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF827717))),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF1F2F4)),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Iconsax.setting_2, size: 16, color: Color(0xFF1A237E)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                          const SizedBox(height: 4),
                          Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Segmented Status
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F2F4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _statusSegment('To-Do', status == 'To-Do'),
                      _statusSegment('In-Progress', status == 'In-Progress'),
                      _statusSegment('Done', status == 'Done'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      if (priority == 'ACTIVE JOB') {
                        if (status == 'To-Do') {
                          ref.read(technicianProvider.notifier).startJob();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Job started!'), backgroundColor: Color(0xFF1A237E)),
                          );
                        } else {
                          context.push('/tech-job-card-details');
                        }
                      } else {
                        context.push('/tech-job-card-details');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: status == 'Done' ? Colors.white : const Color(0xFF1A237E),
                      foregroundColor: status == 'Done' ? const Color(0xFF1A237E) : Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: status == 'Done' ? const BorderSide(color: Color(0xFFE5E9F0)) : BorderSide.none,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (status == 'To-Do') const Icon(Icons.play_arrow_rounded, size: 20),
                        if (status == 'In-Progress') const Icon(Icons.check_circle_outline, size: 20),
                        if (status == 'Done') const Icon(Icons.visibility_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          status == 'Done' ? 'View Report' : (status == 'To-Do' ? 'Start Work' : 'Manage Job'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _statusSegment(String label, bool isActive) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? const Color(0xFF1A237E) : Colors.grey[600],
          ),
        ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? const Color(0xFF1A237E) : Colors.grey, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? const Color(0xFF1A237E) : Colors.grey)),
        ],
      ),
    );
  }
}
