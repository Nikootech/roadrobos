import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/repositories/user_vehicle_repository.dart';
import '../profile/user_provider.dart';
import 'vehicle_list_provider.dart';
import '../../shared/widgets/custom_text_field.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  final UserVehicle? vehicle;

  const AddVehicleScreen({super.key, this.vehicle});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _plateController;
  int? _selectedYear;
  String _selectedType = 'car';
  bool _isSaving = false;

  final List<int> _yearsList = List.generate(12, (index) => 2015 + index); // 2015 to 2026

  final List<Map<String, dynamic>> _types = [
    {'value': 'car', 'label': 'Car', 'icon': Icons.directions_car_rounded},
    {'value': 'bike', 'label': 'Bike', 'icon': Icons.directions_bike_rounded},
    {'value': 'ev', 'label': 'EV', 'icon': Icons.electric_bike_rounded},
    {'value': 'truck', 'label': 'Truck', 'icon': Icons.local_shipping_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _makeController = TextEditingController(text: widget.vehicle?.make ?? '');
    _modelController = TextEditingController(text: widget.vehicle?.model ?? '');
    _plateController = TextEditingController(text: widget.vehicle?.plateNumber ?? '');
    _selectedYear = widget.vehicle?.year ?? 2023;
    _selectedType = widget.vehicle?.vehicleType.toLowerCase() ?? 'car';
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final userState = ref.read(userProvider);
    final userId = userState.user?.id;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User session not found. Please log in.'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final vehicleData = UserVehicle(
        id: widget.vehicle?.id ?? '',
        userId: userId,
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: _selectedYear ?? 2023,
        plateNumber: _plateController.text.trim().toUpperCase(),
        vehicleType: _selectedType,
        isPrimary: widget.vehicle?.isPrimary ?? false,
      );

      if (widget.vehicle != null) {
        await ref.read(vehicleListProvider.notifier).updateVehicle(vehicleData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehicle updated successfully!'),
              backgroundColor: AppColors.successDark,
            ),
          );
        }
      } else {
        await ref.read(vehicleListProvider.notifier).addVehicle(vehicleData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehicle added successfully!'),
              backgroundColor: AppColors.successDark,
            ),
          );
        }
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.vehicle != null;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          isEditMode ? 'Edit Vehicle' : 'Add Vehicle',
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vehicle Type segmented control
                      Text(
                        'Vehicle Type',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: _types.map((type) {
                          final isSelected = _selectedType == type['value'];
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedType = type['value'];
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryBlue
                                        : AppColors.border,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      type['icon'] as IconData,
                                      color: isSelected
                                          ? AppColors.primaryBlue
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      type['label'] as String,
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.primaryBlue
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Make field
                      CustomTextField(
                        controller: _makeController,
                        label: 'Make / Brand',
                        hint: 'e.g. Toyota, Honda, Tesla',
                        prefixIcon: Icons.corporate_fare_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the brand/make';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Model field
                      CustomTextField(
                        controller: _modelController,
                        label: 'Model',
                        hint: 'e.g. Camry, Civic, Model 3',
                        prefixIcon: Icons.model_training_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the model';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Year dropdown
                      Text(
                        'Year of Manufacture',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedYear,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.bgLightCard,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                        items: _yearsList.map((int year) {
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(
                              year.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            _selectedYear = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a year';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Plate Number
                      CustomTextField(
                        controller: _plateController,
                        label: 'Plate Number',
                        hint: 'e.g. MH 12 AB 1234',
                        prefixIcon: Icons.pin_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the license plate';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            // Floating Save Button at bottom
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepNavy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isEditMode ? 'SAVE CHANGES' : 'ADD VEHICLE',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
