import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/repositories/storage_repository.dart';
import '../../core/repositories/kyc_repository.dart';
import '../../shared/widgets/custom_button.dart';
import '../../core/services/auth_service.dart';

class PartnerKycScreen extends ConsumerStatefulWidget {
  const PartnerKycScreen({super.key});

  @override
  ConsumerState<PartnerKycScreen> createState() => _PartnerKycScreenState();
}

class _PartnerKycScreenState extends ConsumerState<PartnerKycScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _aadharFront;
  File? _aadharBack;
  File? _drivingLicense;
  bool _isUploading = false;

  Future<void> _pickImage(String docType) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (docType == 'aadhar_front') _aadharFront = File(image.path);
        if (docType == 'aadhar_back') _aadharBack = File(image.path);
        if (docType == 'dl') _drivingLicense = File(image.path);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_aadharFront == null || _aadharBack == null || _drivingLicense == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required documents')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) throw Exception('Not authenticated');

      final storage = ref.read(storageRepositoryProvider);
      
      // Upload documents
      final aadharFrontUrl = await storage.uploadFile(
        bucket: 'kyc-documents',
        path: '${user.id}/aadhar_front',
        file: _aadharFront!,
      );

      final aadharBackUrl = await storage.uploadFile(
        bucket: 'kyc-documents',
        path: '${user.id}/aadhar_back',
        file: _aadharBack!,
      );

      final dlUrl = await storage.uploadFile(
        bucket: 'kyc-documents',
        path: '${user.id}/driving_license',
        file: _drivingLicense!,
      );

      // Save to DB
      final kycRepo = ref.read(kycRepositoryProvider);
      
      await kycRepo.submitKyc(
        userId: user.id,
        documentType: 'aadhar_front',
        documentUrl: aadharFrontUrl,
      );

      await kycRepo.submitKyc(
        userId: user.id,
        documentType: 'aadhar_back',
        documentUrl: aadharBackUrl,
      );

      await kycRepo.submitKyc(
        userId: user.id,
        documentType: 'driving_license',
        documentUrl: dlUrl,
      );

      if (!mounted) return;
      context.go('/driver-home');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('KYC Submitted for review!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Partner KYC', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Document Verification',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload clear photos of your documents for verification.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            
            _buildUploadCard('Aadhar Card (Front)', _aadharFront, () => _pickImage('aadhar_front')),
            const SizedBox(height: 16),
            _buildUploadCard('Aadhar Card (Back)', _aadharBack, () => _pickImage('aadhar_back')),
            const SizedBox(height: 16),
            _buildUploadCard('Driving License', _drivingLicense, () => _pickImage('dl')),
            
            const SizedBox(height: 48),
            CustomButton(
              label: 'SUBMIT FOR REVIEW',
              onPressed: _handleSubmit,
              isLoading: _isUploading,
            ),
          ],
        ).animate().fadeIn().slideY(begin: 0.1, end: 0),
      ),
    );
  }

  Widget _buildUploadCard(String title, File? file, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: file != null ? AppColors.brandGreen : AppColors.border, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.bgLightGrey,
                borderRadius: BorderRadius.circular(12),
                image: file != null ? DecorationImage(image: FileImage(file), fit: BoxFit.cover) : null,
              ),
              child: file == null ? const Icon(Icons.add_a_photo_rounded, color: AppColors.textMuted) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(file != null ? 'Image selected' : 'Tap to upload photo', style: TextStyle(fontSize: 12, color: file != null ? AppColors.brandGreen : AppColors.textSecondary)),
                ],
              ),
            ),
            if (file != null) const Icon(Icons.check_circle_rounded, color: AppColors.brandGreen),
          ],
        ),
      ),
    );
  }
}
