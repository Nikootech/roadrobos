import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/repositories/storage_repository.dart';
import '../../../core/repositories/kyc_repository.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/custom_button.dart';

class KycUploadScreen extends ConsumerStatefulWidget {
  final String? initialStep;
  const KycUploadScreen({super.key, this.initialStep});

  @override
  ConsumerState<KycUploadScreen> createState() => _KycUploadScreenState();
}

class _KycUploadScreenState extends ConsumerState<KycUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  
  File? _aadharFront;
  File? _aadharBack;
  File? _dlFront;
  File? _dlBack;
  File? _vehicleRc;
  File? _selfie;

  int _currentStep = 0;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialStep == 'aadhar') _currentStep = 0;
    if (widget.initialStep == 'driving_license') _currentStep = 1;
    if (widget.initialStep == 'vehicle_rc') _currentStep = 2;
    if (widget.initialStep == 'selfie') _currentStep = 3;
  }

  Future<File?> _compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 75,
      minWidth: 800,
      minHeight: 800,
    );
    return result != null ? File(result.path) : null;
  }

  Future<void> _pickImage(String docType, {bool useCamera = false}) async {
    final source = useCamera ? ImageSource.camera : ImageSource.gallery;
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      final file = File(image.path);
      setState(() {
        if (docType == 'aadhar_front') _aadharFront = file;
        if (docType == 'aadhar_back') _aadharBack = file;
        if (docType == 'dl_front') _dlFront = file;
        if (docType == 'dl_back') _dlBack = file;
        if (docType == 'vehicle_rc') _vehicleRc = file;
        if (docType == 'selfie') _selfie = file;
      });
    }
  }

  Future<String?> _uploadDocument(File file, String docType, String userId) async {
    try {
      final compressedFile = await _compressImage(file);
      if (compressedFile == null) throw Exception('Image compression failed');

      final storage = ref.read(storageRepositoryProvider);
      return await storage.uploadFile(
        bucket: 'kyc-documents',
        path: '$userId/${docType}_${DateTime.now().millisecondsSinceEpoch}',
        file: compressedFile,
      );
    } catch (e) {
      debugPrint('Error uploading $docType: $e');
      return null;
    }
  }

  Future<void> _submitStep() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not authenticated')));
      return;
    }

    final kycRepo = ref.read(kycRepositoryProvider);
    setState(() => _isUploading = true);

    bool stepSuccess = true;

    try {
      if (_currentStep == 0) {
        if (_aadharFront == null || _aadharBack == null) throw Exception('Aadhaar front and back required');
        final frontUrl = await _uploadDocument(_aadharFront!, 'aadhar_front', user.id);
        final backUrl = await _uploadDocument(_aadharBack!, 'aadhar_back', user.id);
        if (frontUrl != null) await kycRepo.submitKyc(userId: user.id, documentType: 'aadhar_front', documentUrl: frontUrl);
        if (backUrl != null) await kycRepo.submitKyc(userId: user.id, documentType: 'aadhar_back', documentUrl: backUrl);
      } else if (_currentStep == 1) {
        if (_dlFront == null || _dlBack == null) throw Exception('DL front and back required');
        final frontUrl = await _uploadDocument(_dlFront!, 'dl_front', user.id);
        final backUrl = await _uploadDocument(_dlBack!, 'dl_back', user.id);
        if (frontUrl != null) await kycRepo.submitKyc(userId: user.id, documentType: 'driving_license_front', documentUrl: frontUrl);
        if (backUrl != null) await kycRepo.submitKyc(userId: user.id, documentType: 'driving_license_back', documentUrl: backUrl);
      } else if (_currentStep == 2) {
        if (_vehicleRc == null) throw Exception('Vehicle RC required');
        final rcUrl = await _uploadDocument(_vehicleRc!, 'vehicle_rc', user.id);
        if (rcUrl != null) await kycRepo.submitKyc(userId: user.id, documentType: 'vehicle_rc', documentUrl: rcUrl);
      } else if (_currentStep == 3) {
        if (_selfie == null) throw Exception('Selfie required');
        final selfieUrl = await _uploadDocument(_selfie!, 'selfie', user.id);
        if (selfieUrl != null) await kycRepo.submitKyc(userId: user.id, documentType: 'selfie', documentUrl: selfieUrl);
      }
    } catch (e) {
      stepSuccess = false;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }

    if (stepSuccess && mounted) {
      if (_currentStep < 3) {
        setState(() => _currentStep++);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All documents uploaded successfully!')));
        context.go('/driver/kyc-status');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        title: const Text('Driver KYC', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: _isUploading ? null : _submitStep,
        onStepCancel: _currentStep > 0 ? () => setState(() => _currentStep--) : null,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: _currentStep == 3 ? 'FINISH' : 'UPLOAD & CONTINUE',
                    onPressed: details.onStepContinue,
                    isLoading: _isUploading,
                  ),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Aadhaar Card'),
            content: Column(
              children: [
                _buildUploadCard('Aadhaar Front', _aadharFront, () => _pickImage('aadhar_front')),
                const SizedBox(height: 16),
                _buildUploadCard('Aadhaar Back', _aadharBack, () => _pickImage('aadhar_back')),
              ],
            ).animate().fade(),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Driving License'),
            content: Column(
              children: [
                _buildUploadCard('License Front', _dlFront, () => _pickImage('dl_front')),
                const SizedBox(height: 16),
                _buildUploadCard('License Back', _dlBack, () => _pickImage('dl_back')),
              ],
            ).animate().fade(),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Vehicle RC'),
            content: Column(
              children: [
                _buildUploadCard('Vehicle RC Photo', _vehicleRc, () => _pickImage('vehicle_rc')),
              ],
            ).animate().fade(),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Selfie with Aadhaar'),
            content: Column(
              children: [
                const Text('Please take a clear selfie holding your Aadhaar card next to your face.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 16),
                _buildUploadCard('Selfie', _selfie, () => _pickImage('selfie', useCamera: true)),
              ],
            ).animate().fade(),
            isActive: _currentStep >= 3,
            state: _currentStep > 3 ? StepState.complete : StepState.indexed,
          ),
        ],
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
            if (file != null) ...[
              const Icon(Icons.check_circle_rounded, color: AppColors.brandGreen),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.textMuted),
                onPressed: onTap,
                tooltip: 'Retake photo',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
