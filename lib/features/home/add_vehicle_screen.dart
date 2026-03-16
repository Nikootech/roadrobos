import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

/// Add New Vehicle Screen matching Figma Screen [60]: "Add New Vehicle"
/// Upload section, vehicle details form, registration & legal, sticky footer
class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  String _selectedFuelType = 'Petrol';
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

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
              // Header (390x73, from Figma)
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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                title: const Text(
                  AppStrings.addNewVehicle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              // Upload RC/Photo Section (358x168, radius 16)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  height: 168,
                  decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.border,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: _pickedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(_pickedImage!.path),
                              width: double.infinity,
                              height: 168,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Iconsax.camera,
                                  color: AppColors.primaryBlue,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Upload Vehicle Photo / RC',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'JPEG, PNG up to 5MB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.05, end: 0),
              ),

              // Vehicle Details Card (358x366, radius 16)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vehicle Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        label: AppStrings.vehicleName,
                        hint: 'e.g. Hyundai Creta',
                        prefixIcon: Iconsax.car,
                      ),
                      SizedBox(height: 14),
                      CustomTextField(
                        label: AppStrings.vehicleModel,
                        hint: 'e.g. SX (O) 1.5 Turbo',
                        prefixIcon: Iconsax.tag,
                      ),
                      SizedBox(height: 14),
                      CustomTextField(
                        label: AppStrings.licensePlate,
                        hint: 'e.g. MH 02 AB 1234',
                        prefixIcon: Iconsax.document_text,
                      ),
                      SizedBox(height: 14),
                      CustomTextField(
                        label: AppStrings.yearOfManufacture,
                        hint: 'e.g. 2023',
                        prefixIcon: Iconsax.calendar,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.05, end: 0),
              ),

              // Fuel Type Selection (Preferences Card 358x74, radius 16)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fuel Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
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
                                  color: isSelected
                                      ? AppColors.primaryBlue
                                      : AppColors.bgLightCard,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryBlue
                                        : AppColors.border,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    fuel,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 400.ms),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

          // Sticky Footer (390x97 from Figma)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: const BoxDecoration(
                color: AppColors.bgWhite,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowMedium,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              // Button (358x48, fill #18207C, radius 12 from Figma)
              child: CustomButton(
                label: AppStrings.save,
                onPressed: () => context.pop(),
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
}

