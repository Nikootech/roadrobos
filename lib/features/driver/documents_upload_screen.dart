import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart'; // ADDED
import 'dart:io';
import 'dart:ui';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/shimmer_loading.dart';

class DocumentsUploadScreen extends StatefulWidget {
  const DocumentsUploadScreen({super.key});

  @override
  State<DocumentsUploadScreen> createState() => _DocumentsUploadScreenState();
}

class _DocumentsUploadScreenState extends State<DocumentsUploadScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bikeModelController = TextEditingController();
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
      setState(() => _uploadingDocs[key] = true);
      // Simulate network upload with shimmer
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() {
          _docs[key] = image;
          _uploadingDocs[key] = false;
        });
      }
    }
  }

  bool get _isAllValid {
    // Basic validation: all docs filled and inputs not empty
    return _nameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _bikeModelController.text.isNotEmpty &&
        _licenseController.text.isNotEmpty &&
        !_docs.values.contains(null);
  }

  @override
  Widget build(BuildContext context) {
    int uploadedCount = _docs.values.where((v) => v != null).length;
    
    return Scaffold(
      backgroundColor: AppColors.brandGreenBg, // Updated to brand green background
      body: Stack(
        children: [
          // Background abstract shape
          Positioned(
            top: -100, right: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                width: 350, height: 350,
                decoration: BoxDecoration(
                  color: AppColors.brandGreenLight.withValues(alpha: 0.15), 
                  shape: BoxShape.circle
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GlassCard(
                blur: 20,
                border: Border.all(color: AppColors.brandGreen.withValues(alpha: 0.2)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Captain Onboarding', 
                      style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.brandGreen)
                    ).animate().fadeIn(duration: 400.ms).slideX(),
                    const SizedBox(height: 8),
                    const Text('Let\'s get your documents verified to start earning.', style: TextStyle(color: AppColors.textSecondary)).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 24),
                    
                    // Progress Tracker
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: AppColors.brandGreen.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                        ]
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: AppColors.brandGreenBg, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Iconsax.verify, color: AppColors.brandGreen, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Document Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: uploadedCount / 8, 
                                    backgroundColor: AppColors.bgLightGrey, 
                                    valueColor: const AlwaysStoppedAnimation(AppColors.brandGreen), 
                                    minHeight: 6
                                  ),
                                )
                              ]
                            )
                          ),
                          const SizedBox(width: 16),
                          Text('$uploadedCount/8', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.brandGreen)),
                        ]
                      )
                    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),

                    const SizedBox(height: 32),
                    
                    // Personal Details
                    const Text('Personal Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                        ]
                      ),
                      child: Column(
                        children: [
                          CustomTextField(controller: _nameController, hint: 'Full Name', prefixIcon: Iconsax.user, onChanged: (_) => setState((){})),
                          CustomTextField(controller: _phoneController, hint: 'Phone Number', prefixIcon: Iconsax.mobile, keyboardType: TextInputType.phone, onChanged: (_) => setState((){})),
                          CustomTextField(controller: _bikeModelController, hint: 'Bike Model (e.g. Splendor)', prefixIcon: Iconsax.lovely, onChanged: (_) => setState((){})),
                          CustomTextField(controller: _licenseController, hint: 'Driving License Number', prefixIcon: Iconsax.card, onChanged: (_) => setState((){})),
                        ],
                      )
                    ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1),
                    
                    const SizedBox(height: 40),
                    
                    // Documents
                    const Text('Document Uploads', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
                    
                    const SizedBox(height: 40),
                    
                    // Submit Button
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: _isAllValid ? [
                          BoxShadow(color: AppColors.brandGreen.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 8))
                        ] : [],
                      ),
                      child: CustomButton(
                        label: 'SUBMIT FOR VERIFICATION',
                        onPressed: _isAllValid ? () => context.pushReplacement('/driver-verification-pending') : null,
                        backgroundColor: AppColors.brandGreen,
                      ),
                    ).animate(target: _isAllValid ? 1 : 0).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutBack),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadZone(String title) {
    bool isUploading = _uploadingDocs[title] ?? false;
    XFile? file = _docs[title];

    Widget content;
    if (isUploading) {
      content = const ShimmerLoading(width: double.infinity, height: double.infinity, borderRadius: 16);
    } else if (file != null) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(file.path), fit: BoxFit.cover),
            Container(color: AppColors.brandGreen.withValues(alpha: 0.8)), // Brand green success overlay
            Center(
              child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 40)
                  .animate().scale(begin: const Offset(0, 0), curve: Curves.elasticOut),
            ),
          ],
        ),
      );
    } else {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.brandGreenBg, shape: BoxShape.circle),
            child: const Icon(Iconsax.document_upload, color: AppColors.brandGreen, size: 28),
          ),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.brandGreen)),
        ],
      );
    }

    return GestureDetector(
      onTap: () => _pickDocument(title),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: file != null ? AppColors.brandGreen : AppColors.brandGreen.withValues(alpha: 0.2), 
            width: file != null ? 2 : 1.5
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))
          ]
        ),
        child: content,
      ),
    );
  }
}
