import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../features/home/vehicle_provider.dart';
import '../profile/user_provider.dart';
import '../../shared/widgets/kinetic_motion.dart';
import '../../shared/widgets/sos_button.dart';

/// Add New Vehicle Screen - React Tier-1 Modern Fleet Registration Design
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

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (_nameController.text.trim().isEmpty ||
        _plateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter vehicle name and license plate',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final user = ref.read(userProvider).user;
    final newVehicle = Vehicle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user?.id ?? 'demo',
      name: _nameController.text.trim(),
      plate: _plateController.text.trim().toUpperCase(),
      fuel: _selectedFuelType,
      year: _yearController.text.trim(),
      type: _selectedCategory,
      fcExpiry: _fcExpiry,
      insuranceExpiry: _insuranceExpiry,
      taxExpiry: _taxExpiry,
    );

    ref.read(allVehiclesProvider.notifier).addVehicle(newVehicle);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vehicle added to your garage! ✓',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFF006241),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  Future<void> _pickImage() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Upload Vehicle Photo',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ScaleOnTap(
                      onTap: () async {
                        Navigator.pop(context);
                        try {
                          final XFile? image = await _picker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 80,
                          );
                          if (image != null) {
                            setState(() => _pickedImage = image);
                          }
                        } catch (e) {
                          debugPrint('Error picking image from camera: $e');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Iconsax.camera,
                                  color: Color(0xFF006241), size: 22),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Take Photo',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ScaleOnTap(
                      onTap: () async {
                        Navigator.pop(context);
                        try {
                          final XFile? image = await _picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 80,
                          );
                          if (image != null) {
                            setState(() => _pickedImage = image);
                          }
                        } catch (e) {
                          debugPrint('Error picking image from gallery: $e');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Iconsax.gallery,
                                  color: Color(0xFF006241), size: 22),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Choose Gallery',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
          'Add New Vehicle',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: SOSButton.headerPill(
              rideDetails: 'Fleet Registration',
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── CATEGORY SELECTION ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vehicle Category',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _buildCategoryTile('Car', Iconsax.car),
                            const SizedBox(width: 10),
                            _buildCategoryTile('Bike', Iconsax.driving),
                            const SizedBox(width: 10),
                            _buildCategoryTile('EV Bike', Iconsax.flash_1),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── PHOTO UPLOAD CARD ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: ScaleOnTap(
                    onTap: _pickImage,
                    child: Container(
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: _pickedImage != null
                              ? const Color(0xFF006241)
                              : const Color(0xFFCBD5E1),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: _pickedImage != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.file(
                                    File(_pickedImage!.path),
                                    width: double.infinity,
                                    height: 130,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit_rounded,
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Iconsax.camera,
                                      color: Color(0xFF006241), size: 22),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Upload Vehicle Photo',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  'Tap to capture or upload from gallery',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),

              // ── VEHICLE DETAILS FORM (CLEAN REACT INPUTS) ─────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vehicle Details',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildReactInputField(
                          controller: _nameController,
                          label: 'Vehicle Name / Brand',
                          hint: _selectedCategory == 'Car'
                              ? 'e.g. Hyundai Creta'
                              : (_selectedCategory == 'Bike'
                                  ? 'e.g. Royal Enfield'
                                  : 'e.g. Revolt RV400'),
                          icon: Iconsax.car,
                        ),
                        const SizedBox(height: 12),
                        _buildReactInputField(
                          controller: _modelController,
                          label: 'Vehicle Model & Variant',
                          hint: 'e.g. SX (O) 1.5 Turbo',
                          icon: Iconsax.tag,
                        ),
                        const SizedBox(height: 12),
                        _buildReactInputField(
                          controller: _plateController,
                          label: 'License Plate Number',
                          hint: 'e.g. KA 01 AB 1234',
                          icon: Iconsax.card,
                          textCapitalization: TextCapitalization.characters,
                        ),
                        const SizedBox(height: 12),
                        _buildReactInputField(
                          controller: _yearController,
                          label: 'Year of Manufacture',
                          hint: 'e.g. 2024',
                          icon: Iconsax.calendar_1,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── COMPLIANCE & LEGAL DATES ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Compliance & Expiry Dates',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildDatePickerTile(
                          label: 'Fitness Certificate (FC) Expiry',
                          date: _fcExpiry,
                          icon: Iconsax.document_text,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _fcExpiry ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2040),
                            );
                            if (picked != null) {
                              setState(() => _fcExpiry = picked);
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildDatePickerTile(
                          label: 'Insurance Policy Expiry',
                          date: _insuranceExpiry,
                          icon: Iconsax.shield_tick,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _insuranceExpiry ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2040),
                            );
                            if (picked != null) {
                              setState(() => _insuranceExpiry = picked);
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildDatePickerTile(
                          label: 'Road Tax Expiry',
                          date: _taxExpiry,
                          icon: Iconsax.receipt_2,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _taxExpiry ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2040),
                            );
                            if (picked != null) {
                              setState(() => _taxExpiry = picked);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── FUEL TYPE SELECTOR ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fuel Type',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children:
                              ['Petrol', 'Diesel', 'EV', 'CNG'].map((fuel) {
                            final isSelected = _selectedFuelType == fuel;
                            return Expanded(
                              child: ScaleOnTap(
                                onTap: () =>
                                    setState(() => _selectedFuelType = fuel),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFF006241),
                                              Color(0xFF10B981)
                                            ],
                                          )
                                        : null,
                                    color: isSelected
                                        ? null
                                        : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF006241)
                                          : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      fuel,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.5,
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF475569),
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
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),

          // ── STICKY SAVE VEHICLE CTA ────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                  top: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: ScaleOnTap(
                onTap: _saveVehicle,
                child: Container(
                  height: 52,
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
                    child: Text(
                      'SAVE VEHICLE',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(String label, IconData icon) {
    final isSelected = _selectedCategory == label;

    return Expanded(
      child: ScaleOnTap(
        onTap: () => setState(() => _selectedCategory = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF006241), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF006241)
                  : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1.1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF006241).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF006241),
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReactInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF006241), size: 18),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFF006241), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerTile({
    required String label,
    required DateTime? date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final dateStr = date != null
        ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
        : 'Select Expiry Date';

    return ScaleOnTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF006241), size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight:
                          date != null ? FontWeight.w700 : FontWeight.w500,
                      color: date != null
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.calendar_month_rounded,
                size: 16, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }
}
