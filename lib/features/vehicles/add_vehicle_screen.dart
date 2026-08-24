import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/repositories/user_vehicle_repository.dart';
import '../profile/user_provider.dart';
import 'vehicle_list_provider.dart';
import '../../shared/widgets/kinetic_motion.dart';

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

  DateTime? _fcExpiry;
  DateTime? _insuranceExpiry;
  DateTime? _taxExpiry;

  final List<int> _yearsList =
      List.generate(15, (index) => 2012 + index); // 2012 to 2026

  final List<Map<String, dynamic>> _types = const [
    {
      'value': 'car',
      'label': 'Car',
      'icon': Iconsax.car,
      'gradient': [Color(0xFF006241), Color(0xFF10B981)],
    },
    {
      'value': 'bike',
      'label': 'Bike',
      'icon': Iconsax.activity,
      'gradient': [Color(0xFF0284C7), Color(0xFF38BDF8)],
    },
    {
      'value': 'ev',
      'label': 'EV',
      'icon': Iconsax.flash_1,
      'gradient': [Color(0xFF0D9488), Color(0xFF14B8A6)],
    },
    {
      'value': 'truck',
      'label': 'Truck',
      'icon': Iconsax.truck_fast,
      'gradient': [Color(0xFFD97706), Color(0xFFFBBF24)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _makeController = TextEditingController(text: widget.vehicle?.make ?? '');
    _modelController = TextEditingController(text: widget.vehicle?.model ?? '');
    _plateController =
        TextEditingController(text: widget.vehicle?.plateNumber ?? '');
    _selectedYear = widget.vehicle?.year ?? 2023;
    _selectedType = widget.vehicle?.vehicleType.toLowerCase() ?? 'car';
    _fcExpiry = widget.vehicle?.fcExpiry;
    _insuranceExpiry = widget.vehicle?.insuranceExpiry;
    _taxExpiry = widget.vehicle?.taxExpiry;
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
          behavior: SnackBarBehavior.floating,
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
        fcExpiry: _fcExpiry,
        insuranceExpiry: _insuranceExpiry,
        taxExpiry: _taxExpiry,
      );

      if (widget.vehicle != null) {
        await ref.read(vehicleListProvider.notifier).updateVehicle(vehicleData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehicle updated successfully!'),
              backgroundColor: Color(0xFF006241),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        await ref.read(vehicleListProvider.notifier).addVehicle(vehicleData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehicle added to your garage!'),
              backgroundColor: Color(0xFF006241),
              behavior: SnackBarBehavior.floating,
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
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context, String fieldType) async {
    final initialDate = (fieldType == 'fc'
            ? _fcExpiry
            : fieldType == 'insurance'
                ? _insuranceExpiry
                : _taxExpiry) ??
        DateTime.now().add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF006241),
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (fieldType == 'fc') {
          _fcExpiry = picked;
        } else if (fieldType == 'insurance') {
          _insuranceExpiry = picked;
        } else if (fieldType == 'tax') {
          _taxExpiry = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.vehicle != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        leading: Center(
          child: ScaleOnTap(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Color(0xFF0F172A)),
            ),
          ),
        ),
        title: Text(
          isEditMode ? 'Edit Vehicle' : 'Add Vehicle',
          style: GoogleFonts.outfit(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section: Vehicle Type Selector
                      Text(
                        'Vehicle Type',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: _types.map((type) {
                          final isSelected = _selectedType == type['value'];
                          final gradient = type['gradient'] as List<Color>;

                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: ScaleOnTap(
                                onTap: () {
                                  setState(() {
                                    _selectedType = type['value'];
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                            colors: gradient,
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color: isSelected ? null : Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.transparent
                                          : const Color(0xFFE2E8F0),
                                      width: 1.2,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: gradient.first
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.02),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        type['icon'] as IconData,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF64748B),
                                        size: 22,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        type['label'] as String,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF475569),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Make / Brand
                      _buildModernInputField(
                        controller: _makeController,
                        label: 'Make / Brand',
                        hint: 'e.g. Toyota, Honda, Tesla',
                        icon: Iconsax.building_3,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter make or brand'
                            : null,
                      ),
                      const SizedBox(height: 18),

                      // Model
                      _buildModernInputField(
                        controller: _modelController,
                        label: 'Model',
                        hint: 'e.g. Camry, Civic, Model 3',
                        icon: Iconsax.car,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter model name'
                            : null,
                      ),
                      const SizedBox(height: 18),

                      // Year of Manufacture Dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Year of Manufacture',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            initialValue: _selectedYear,
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF64748B)),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Container(
                                margin:
                                    const EdgeInsets.only(left: 12, right: 12),
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Iconsax.calendar_1,
                                    color: Color(0xFF006241), size: 18),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0), width: 1.2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0), width: 1.2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                    color: Color(0xFF006241), width: 1.5),
                              ),
                            ),
                            items: _yearsList.map((int year) {
                              return DropdownMenuItem<int>(
                                value: year,
                                child: Text(year.toString()),
                              );
                            }).toList(),
                            onChanged: (int? newVal) {
                              setState(() => _selectedYear = newVal);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Plate Number
                      _buildModernInputField(
                        controller: _plateController,
                        label: 'Plate Number',
                        hint: 'e.g. MH 12 AB 1234',
                        icon: Iconsax.card,
                        textCapitalization: TextCapitalization.characters,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter license plate'
                            : null,
                      ),
                      const SizedBox(height: 18),

                      // FC Expiry
                      _buildDatePickerTile(
                        title: 'Fitness Certificate (FC) Expiry',
                        date: _fcExpiry,
                        icon: Iconsax.document_text_1,
                        onTap: () => _selectDate(context, 'fc'),
                      ),
                      const SizedBox(height: 18),

                      // Insurance Expiry
                      _buildDatePickerTile(
                        title: 'Insurance Expiry',
                        date: _insuranceExpiry,
                        icon: Iconsax.shield_tick,
                        onTap: () => _selectDate(context, 'insurance'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Sticky CTA
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ScaleOnTap(
                onTap: _isSaving ? null : _submitForm,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF006241), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF006241).withValues(alpha: 0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            isEditMode ? 'UPDATE VEHICLE' : 'ADD VEHICLE',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          textCapitalization: textCapitalization,
          validator: validator,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.only(left: 12, right: 12),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF006241), size: 18),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide:
                  const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide:
                  const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide:
                  const BorderSide(color: Color(0xFF006241), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerTile({
    required String title,
    required DateTime? date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final formatted =
        date != null ? DateFormat('MMM dd, yyyy').format(date) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        ScaleOnTap(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF006241), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    formatted ?? 'Select Expiry Date',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight:
                          formatted != null ? FontWeight.w700 : FontWeight.w500,
                      color: formatted != null
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
                const Icon(Iconsax.calendar,
                    color: Color(0xFF64748B), size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
