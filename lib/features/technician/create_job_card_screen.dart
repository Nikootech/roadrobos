import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'technician_provider.dart';

class CreateJobCardScreen extends ConsumerStatefulWidget {
  const CreateJobCardScreen({super.key});

  @override
  ConsumerState<CreateJobCardScreen> createState() => _CreateJobCardScreenState();
}

class _CreateJobCardScreenState extends ConsumerState<CreateJobCardScreen> {
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _regNoController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  
  String? _selectedTechnician;
  DateTime _estimatedCompletion = DateTime.now().add(const Duration(hours: 4));
  
  final List<Map<String, dynamic>> _scopeItems = [];

  final List<String> _technicians = ['Arun Kumar', 'Suresh Raina', 'Vikram Singh', 'Manoj Bajpayee'];

  @override
  void dispose() {
    _vehicleModelController.dispose();
    _regNoController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  void _generateJobCard() {
    if (_selectedTechnician == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a technician'), backgroundColor: Colors.orange),
      );
      return;
    }

    final newJob = TechnicianJob(
      id: 'JOB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      estimatedCompletion: DateFormat('hh:mm a').format(_estimatedCompletion),
      vehicleModel: _vehicleModelController.text.isEmpty ? 'Unknown Model' : _vehicleModelController.text,
      vehiclePlate: _regNoController.text.isEmpty ? 'Unknown Plate' : _regNoController.text,
      progress: 0.0,
      checklist: _scopeItems.map((item) => ChecklistItem(task: item['title'] as String, category: 'Service')).toList(),
      parts: [],
      status: 'CREATED',
    );

    ref.read(technicianProvider.notifier).createJob(newJob);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Job Card Created successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    
    context.pop();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _estimatedCompletion,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && mounted) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_estimatedCompletion),
      );
      if (time != null && mounted) {
        setState(() {
          _estimatedCompletion = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
        });
      }
    }
  }

  void _addServiceItem() {
    setState(() {
      _scopeItems.add({
        'title': 'General Inspection',
        'price': '₹500.00',
        'duration': '1.0h',
        'icon': Iconsax.search_status
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added General Inspection to scope'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
          ),
        ),
        title: Text(
          'Create Job Card', 
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
        ),
        actions: [
          TextButton(
            onPressed: _generateJobCard,
            child: Text('Save', style: GoogleFonts.outfit(color: const Color(0xFF1A237E), fontSize: 16, fontWeight: FontWeight.bold)),
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
                // 1. Vehicle Context (Editable)
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Iconsax.car, size: 18, color: AppColors.primaryNavy),
                          const SizedBox(width: 12),
                          Text('Vehicle Details', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _vehicleModelController,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: 'e.g. 2021 Hyundai Creta SX',
                          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                          labelText: 'Vehicle Model',
                          labelStyle: const TextStyle(color: AppColors.textSecondary),
                          prefixIcon: const Icon(Iconsax.car5, color: AppColors.textTertiary, size: 20),
                          filled: true,
                          fillColor: AppColors.bgLightAlt,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.primaryBlueLight, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _regNoController,
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: 'e.g. MH 12 AB 1234',
                          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14, letterSpacing: 0),
                          labelText: 'Registration Number',
                          labelStyle: const TextStyle(color: AppColors.textSecondary, letterSpacing: 0),
                          prefixIcon: const Icon(Iconsax.note_text4, color: AppColors.textTertiary, size: 20),
                          filled: true,
                          fillColor: AppColors.bgLightAlt,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.primaryBlueLight, width: 2),
                          ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E9F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedTechnician,
                            hint: const Text('Select a technician', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                            items: _technicians.map((String tech) {
                              return DropdownMenuItem<String>(
                                value: tech,
                                child: Text(tech, style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _selectedTechnician = value;
                              });
                            },
                          ),
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
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _mileageController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const Text('km', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectDate,
                          child: _buildSmallCard(
                            title: 'Est. Completion',
                            child: Text(
                              DateFormat('MMM dd, hh:mm a').format(_estimatedCompletion),
                              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A237E)),
                            ),
                          ),
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
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Iconsax.setting_2, size: 18, color: Color(0xFF1A237E)),
                            const SizedBox(width: 12),
                            Text('Scope of Work', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ..._scopeItems.map((item) => _buildScopeItem(item)),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: InkWell(
                          onTap: _addServiceItem,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF5E81AC).withValues(alpha: 0.3)),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.add, color: Color(0xFF1A237E), size: 18),
                                  const SizedBox(width: 8),
                                  Text('Add Service Item', style: GoogleFonts.outfit(color: const Color(0xFF1A237E), fontWeight: FontWeight.bold)),
                                ],
                              ),
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
                          Row(
                            children: [
                              const Icon(Iconsax.camera, size: 18, color: Color(0xFF1A237E)),
                              const SizedBox(width: 12),
                              Text('Pre-Service Photos', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2F6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${_scopeItems.length > 2 ? 3 : 2} Added', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4C566A))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera picker opened...')));
                              },
                              child: _buildAddPhoto()
                            ),
                            const SizedBox(width: 12),
                            _buildPhotoThumb(),
                            const SizedBox(width: 12),
                            _buildPhotoThumb(),
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
              onPressed: _generateJobCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Generate Job Card', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
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
            width: double.infinity,
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
              color: const Color(0xFFE8EAF6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.confirmation_number_rounded, color: Color(0xFF1A237E), size: 18),
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
          IconButton(
            onPressed: () {
              setState(() {
                _scopeItems.remove(item);
              });
            },
            icon: Icon(Icons.remove_circle_outline, color: Colors.red.withValues(alpha: 0.5), size: 20),
          ),
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

  Widget _buildPhotoThumb() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}
