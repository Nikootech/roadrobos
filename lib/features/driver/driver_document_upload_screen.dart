import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import 'driver_provider.dart';

class DriverDocumentUploadScreen extends ConsumerStatefulWidget {
  const DriverDocumentUploadScreen({super.key});

  @override
  ConsumerState<DriverDocumentUploadScreen> createState() => _DriverDocumentUploadScreenState();
}

class _DriverDocumentUploadScreenState extends ConsumerState<DriverDocumentUploadScreen> {
  final Map<String, bool> _uploadedDocs = {
    'Driving License': false,
    'Aadhaar Card': false,
    'Vehicle RC': false,
    'Insurance Policy': false,
    'Pollution Certificate': false,
  };

  void _toggleDoc(String name) {
    HapticFeedback.lightImpact();
    setState(() {
      _uploadedDocs[name] = !(_uploadedDocs[name] ?? false);
    });
  }

  double get _progress => _uploadedDocs.values.where((v) => v).length / _uploadedDocs.length;

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
        title: const Text('Driver Verification', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Registration Steps', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Upload clear photos of the following documents to get started.', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            
            // Progress Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${(_progress * 100).toInt()}% Completed', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                      Text('${_uploadedDocs.values.where((v) => v).length}/${_uploadedDocs.length} Documents', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            ..._uploadedDocs.keys.map((doc) => _buildDocTile(doc)).toList(),
            
            const SizedBox(height: 48),
            CustomButton(
              label: 'Submit Application',
              onPressed: _progress == 1.0 
                ? () {
                    HapticFeedback.mediumImpact();
                    ref.read(driverProvider.notifier).submitDocuments();
                    context.push('/driver-verification-pending');
                  }
                : null,
              backgroundColor: AppColors.primaryBlue,
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'By submitting, you agree to our Terms & Conditions',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocTile(String title) {
    bool isUploaded = _uploadedDocs[title] ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _toggleDoc(title),
        child: AnimatedContainer(
          duration: 300.ms,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUploaded ? AppColors.successGreen.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUploaded ? AppColors.successGreen.withValues(alpha: 0.3) : AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isUploaded ? AppColors.successGreen : AppColors.primaryBlue).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUploaded ? Icons.done_all_rounded : Iconsax.document_upload,
                  size: 20,
                  color: isUploaded ? AppColors.successGreen : AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    Text(isUploaded ? 'Document Uploaded' : 'Tap to upload photo', 
                      style: TextStyle(fontSize: 12, color: isUploaded ? AppColors.successGreen : AppColors.textSecondary)),
                  ],
                ),
              ),
              if (isUploaded)
                const Icon(Icons.check_circle, color: AppColors.successGreen, size: 24)
              else
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
