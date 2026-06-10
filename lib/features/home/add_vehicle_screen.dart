import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

/// Add New Vehicle Screen matching Figma Screen [60]: "Add New Vehicle"
/// Upload section, vehicle details form, registration & legal, sticky footer
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/vehicle_provider.dart';
import '../profile/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  String _selectedCategory = 'Car';
  String _selectedFuelType = 'Petrol';
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  
  final _nameController = TextEditingController();
  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  final _yearController = TextEditingController();

  DateTime? _fcExpiry;
  DateTime? _insuranceExpiry;
  DateTime? _taxExpiry;

  Future<void> _saveVehicle() async {
    if (_nameController.text.isNotEmpty && _plateController.text.isNotEmpty) {
      final user = ref.read(userProvider).user;
      final newVehicle = Vehicle(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user?.id ?? 'demo',
        name: _nameController.text,
        plate: _plateController.text,
        fuel: _selectedFuelType,
        year: _yearController.text,
        type: _selectedCategory,
        fcExpiry: _fcExpiry,
        insuranceExpiry: _insuranceExpiry,
        taxExpiry: _taxExpiry,
      );
      
      ref.read(allVehiclesProvider.notifier).addVehicle(newVehicle);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle added to your garage!'), backgroundColor: AppColors.successGreen),
        );
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightWarm,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: AppColors.bgWhite,
                elevation: 0,
                leading: GestureDetector(
                  onTap: () => context.pop(),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textPrimary),
                    ),
                  ),
                ),
                title: Text(AppStrings.addNewVehicle, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ),

              // Category Selection
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.bgWhite, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vehicle Category', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildCategoryItem('Car', Icons.directions_car_rounded),
                          const SizedBox(width: 12),
                          _buildCategoryItem('Bike', Icons.pedal_bike_rounded),
                          const SizedBox(width: 12),
                          _buildCategoryItem('EV Bike', Icons.electric_bike_rounded),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: _pickedImage != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(File(_pickedImage!.path), width: double.infinity, height: 140, fit: BoxFit.cover))
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, color: AppColors.primaryBlue, size: 28),
                              SizedBox(height: 8),
                              Text('Upload Photo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                            ],
                          ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.bgWhite, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _nameController,
                        label: AppStrings.vehicleName,
                        hint: _selectedCategory == 'Car' ? 'e.g. Hyundai Creta' : (_selectedCategory == 'Bike' ? 'e.g. Royal Enfield' : 'e.g. Revolt RV400'),
                        prefixIcon: _selectedCategory == 'Car' ? Icons.directions_car_outlined : Icons.pedal_bike_outlined,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _modelController,
                        label: AppStrings.vehicleModel,
                        hint: 'e.g. SX (O) 1.5 Turbo',
                        prefixIcon: Icons.label_outline_rounded,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _plateController,
                        label: AppStrings.licensePlate,
                        hint: 'e.g. MH 02 AB 1234',
                        prefixIcon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _yearController,
                        label: AppStrings.yearOfManufacture,
                        hint: 'e.g. 2023',
                        prefixIcon: Icons.calendar_today_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 14),

                      // FC Expiry
                      _buildDatePickerField(
                        label: 'Fitness Certificate (FC) Expiry',
                        hint: 'Select FC Expiry Date',
                        selectedDate: _fcExpiry,
                        prefixIcon: Icons.description_rounded,
                        onDateSelected: (date) => setState(() => _fcExpiry = date),
                      ),
                      const SizedBox(height: 14),

                      // Insurance Expiry
                      _buildDatePickerField(
                        label: 'Insurance Expiry',
                        hint: 'Select Insurance Expiry Date',
                        selectedDate: _insuranceExpiry,
                        prefixIcon: Icons.shield_rounded,
                        onDateSelected: (date) => setState(() => _insuranceExpiry = date),
                      ),
                      const SizedBox(height: 14),

                      // Road Tax Expiry
                      _buildDatePickerField(
                        label: 'Road Tax Expiry',
                        hint: 'Select Road Tax Expiry Date',
                        selectedDate: _taxExpiry,
                        prefixIcon: Icons.receipt_long_rounded,
                        onDateSelected: (date) => setState(() => _taxExpiry = date),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.bgWhite, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fuel Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      Row(
                        children: ['Petrol', 'Diesel', 'EV', 'CNG'].map((fuel) {
                          final isSelected = _selectedFuelType == fuel;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedFuelType = fuel),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primaryBlue : AppColors.bgLightCard,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.border),
                                ),
                                child: Center(
                                  child: Text(fuel, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : AppColors.textSecondary)),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: const BoxDecoration(color: AppColors.bgWhite, boxShadow: [BoxShadow(color: AppColors.shadowMedium, blurRadius: 16, offset: Offset(0, -4))]),
              child: CustomButton(
                label: AppStrings.save,
                onPressed: _saveVehicle,
                backgroundColor: AppColors.deepNavy,
                height: 48,
                borderRadius: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String label, IconData icon) {
    final isSelected = _selectedCategory == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedCategory = label;
          if (label == 'EV Bike') _selectedFuelType = 'EV';
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.border, width: isSelected ? 2 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary, size: 24),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required String hint,
    required DateTime? selectedDate,
    required IconData prefixIcon,
    required ValueChanged<DateTime?> onDateSelected,
  }) {
    final formattedDate = selectedDate != null
        ? '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}'
        : '';
    final controller = TextEditingController(text: formattedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () async {
            final now = DateTime.now();
            final initialDate = selectedDate ?? now;
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(now.year + 10),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.deepNavy,
                      onSurface: AppColors.textPrimary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              onDateSelected(pickedDate);
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 14),
            filled: true,
            fillColor: AppColors.bgLightCard,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            prefixIcon: Icon(prefixIcon, color: AppColors.textMuted, size: 20),
            suffixIcon: selectedDate != null
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted, size: 18),
                    onPressed: () => onDateSelected(null),
                  )
                : const Icon(Icons.calendar_today_rounded, color: AppColors.textMuted, size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
            ),
          ),
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

