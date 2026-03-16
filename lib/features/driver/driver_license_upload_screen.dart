import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';

class DriverLicenseUploadScreen extends StatefulWidget {
  const DriverLicenseUploadScreen({super.key});

  @override
  State<DriverLicenseUploadScreen> createState() => _DriverLicenseUploadScreenState();
}

class _DriverLicenseUploadScreenState extends State<DriverLicenseUploadScreen> {
  XFile? _frontImage;
  XFile? _backImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isFront) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isFront) {
          _frontImage = image;
        } else {
          _backImage = image;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Driving License', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upload Your Documents', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Please upload a clear photo of your driving license (Front & Back).', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            
            _buildUploadCard('Front Side', _frontImage, () => _pickImage(true)),
            const SizedBox(height: 16),
            _buildUploadCard('Back Side', _backImage, () => _pickImage(false)),
            
            const SizedBox(height: 40),
            const Text('Requirements:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildRequirementRow('Images must be clear and readable'),
            _buildRequirementRow('All four corners of the license must be visible'),
            _buildRequirementRow('Format: JPG, PNG (Max 5MB)'),
            
            const SizedBox(height: 60),
            CustomButton(
              label: 'Submit for Verification',
              onPressed: (_frontImage != null && _backImage != null) 
                ? () => context.push('/driver-verification-pending') 
                : null,
              backgroundColor: AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard(String label, XFile? image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.bgLightGrey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(File(image.path), fit: BoxFit.cover),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.camera, color: AppColors.primaryBlue, size: 32),
                const SizedBox(height: 12),
                Text('Upload $label', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildRequirementRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        ],
      ),
    );
  }
}
