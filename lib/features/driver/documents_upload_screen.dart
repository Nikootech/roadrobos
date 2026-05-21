import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/repositories/driver_repository.dart';
import '../profile/user_provider.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/shimmer_loading.dart';

/// Documents Upload Screen — Premium Driver Overhaul
class DocumentsUploadScreen extends ConsumerStatefulWidget {
  const DocumentsUploadScreen({super.key});

  @override
  ConsumerState<DocumentsUploadScreen> createState() => _DocumentsUploadScreenState();
}

class _DocumentsUploadScreenState extends ConsumerState<DocumentsUploadScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bikeModelController = TextEditingController();
  final _chassisController = TextEditingController();
  final _licenseController = TextEditingController();

  final Map<String, XFile?> _docs = {
    'DL Front': null,
    'DL Back': null,
    'Aadhaar/PAN': null,
    'Vehicle RC': null,
    'Insurance': null,
    'PUC': null,
    'Profile Photo': null,
    'Selfie': null,
  };

  final Map<String, bool> _uploadingDocs = {};
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickDocument(String key) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      HapticFeedback.mediumImpact();
      setState(() => _uploadingDocs[key] = true);
      // Simulate network upload with shimmer
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() {
          _docs[key] = image;
          _uploadingDocs[key] = false;
        });
        HapticFeedback.lightImpact();
      }
    }
  }

  bool get _isAllValid {
    return _nameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _bikeModelController.text.isNotEmpty &&
        _chassisController.text.isNotEmpty &&
        _licenseController.text.isNotEmpty &&
        !_docs.values.contains(null);
  }

  @override
  Widget build(BuildContext context) {
    int uploadedCount = _docs.values.where((v) => v != null).length;
    
    return Scaffold(
      backgroundColor: AppColors.bgLightAlt,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Captain Registration', style: TextStyle(color: AppColors.deepNavy, fontWeight: FontWeight.w900, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Text(
              'Welcome, Roadrobo!', 
              style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.deepNavy, letterSpacing: -1)
            ).animate().fadeIn().slideX(),
            const SizedBox(height: 8),
            const Text('Complete your profile to start receiving ride requests today.', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 32),
            
            // Progress Tracker (Premium Blue Style)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8))],
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Iconsax.verify, color: AppColors.primaryBlue, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Verification Progress', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.textPrimary, letterSpacing: 0.2)),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: uploadedCount / 8, 
                            backgroundColor: AppColors.bgLightGrey, 
                            valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue), 
                            minHeight: 6
                          ),
                        )
                      ]
                    )
                  ),
                  const SizedBox(width: 20),
                  Text('$uploadedCount/8', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primaryBlue)),
                ]
              )
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),

            const SizedBox(height: 40),
            
            // Personal Details
            _buildSectionHeader('Personal Details'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  CustomTextField(controller: _nameController, hint: 'Full Name', prefixIcon: Iconsax.user, onChanged: (_) => setState((){})),
                  CustomTextField(controller: _phoneController, hint: 'Phone Number', prefixIcon: Iconsax.mobile, keyboardType: TextInputType.phone, onChanged: (_) => setState((){})),
                  CustomTextField(controller: _bikeModelController, hint: 'Vehicle Model', prefixIcon: Iconsax.lovely, onChanged: (_) => setState((){})),
                  CustomTextField(controller: _chassisController, hint: 'Chassis Number', prefixIcon: Iconsax.hashtag, onChanged: (_) => setState((){})),
                  CustomTextField(controller: _licenseController, hint: 'Driving License No.', prefixIcon: Iconsax.card, onChanged: (_) => setState((){})),
                ],
              )
            ).animate(delay: 300.ms).fadeIn(),
            
            const SizedBox(height: 40),
            
            // Document Grid
            _buildSectionHeader('Document Uploads'),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: _docs.keys.length,
              itemBuilder: (context, index) {
                String key = _docs.keys.elementAt(index);
                return _buildUploadZone(key).animate(delay: (400 + index * 50).ms).fadeIn().scale(begin: const Offset(0.9, 0.9));
              },
            ),
            
            const SizedBox(height: 48),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                label: 'SUBMIT APPLICATION',
                onPressed: _isAllValid ? () async {
                  HapticFeedback.heavyImpact();
                  
                  // Show loading indicator or handle result
                  final userState = ref.read(userProvider);
                  if (userState.user == null) return;
                  
                  final success = await ref.read(driverRepositoryProvider).registerDriver(
                    uid: userState.user!.id,
                    name: _nameController.text,
                    phone: _phoneController.text,
                    vehicleModel: _bikeModelController.text,
                    chassisNumber: _chassisController.text,
                    licenseNumber: _licenseController.text,
                  );

                  if (!mounted) return;

                  if (success) {
                    if (context.mounted) {
                      context.pushReplacement('/driver-verification-pending');
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Submission failed. Please try again.'), backgroundColor: AppColors.dangerRed),
                      );
                    }
                  }
                } : null,
                backgroundColor: AppColors.deepNavy,
              ),
            ).animate(target: _isAllValid ? 1 : 0).scale(begin: const Offset(0.98, 0.98), curve: Curves.easeOutBack),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 1.5),
    );
  }

  Widget _buildUploadZone(String title) {
    bool isUploading = _uploadingDocs[title] ?? false;
    XFile? file = _docs[title];

    Widget content;
    if (isUploading) {
      content = const ShimmerLoading(width: double.infinity, height: double.infinity, borderRadius: 20);
    } else if (file != null) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(file.path), fit: BoxFit.cover),
            Container(color: AppColors.deepNavy.withValues(alpha: 0.7)),
            const Center(child: Icon(Iconsax.tick_circle, color: Colors.white, size: 32)).animate().scale(curve: Curves.elasticOut),
          ],
        ),
      );
    } else {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: AppColors.bgLightGrey, shape: BoxShape.circle),
            child: const Icon(Iconsax.add, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        ],
      );
    }

    return GestureDetector(
      onTap: () => _pickDocument(title),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: file != null ? AppColors.primaryBlue : Colors.transparent, 
            width: 2
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]
        ),
        child: content,
      ),
    );
  }
}
