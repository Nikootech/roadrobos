import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../navigation/nav_helpers.dart';
import '../../shared/widgets/custom_button.dart';

import '../../shared/widgets/live_map_widget.dart';
import 'technician_provider.dart';

class JobCardDetailsScreen extends ConsumerStatefulWidget {
  const JobCardDetailsScreen({super.key});

  @override
  ConsumerState<JobCardDetailsScreen> createState() => _JobCardDetailsScreenState();
}

class _JobCardDetailsScreenState extends ConsumerState<JobCardDetailsScreen> {
  bool _isEditing = false;
  bool _isSaving = false;
  late TextEditingController _modelController;
  late TextEditingController _plateController;

  @override
  void initState() {
    super.initState();
    final job = ref.read(technicianProvider);
    _modelController = TextEditingController(text: job?.vehicleModel ?? '');
    _plateController = TextEditingController(text: job?.vehiclePlate ?? '');
  }

  @override
  void dispose() {
    _modelController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    HapticFeedback.lightImpact();
    if (_isEditing) {
      _saveVehicleDetails();
    } else {
      setState(() => _isEditing = true);
    }
  }

  Future<void> _saveVehicleDetails() async {
    setState(() => _isSaving = true);
    final model = _modelController.text;
    final plate = _plateController.text;
    await Future.delayed(const Duration(milliseconds: 400)); // Simulate save
    final job = ref.read(technicianProvider);
    if (job != null) {
      ref.read(technicianProvider.notifier).createJob(
        job.copyWith(vehicleModel: model, vehiclePlate: plate),
      );
    }
    if (mounted) {
      setState(() { _isEditing = false; _isSaving = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle details saved!'), backgroundColor: AppColors.successGreen, duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobState = ref.watch(technicianProvider);

    if (jobState == null) {
      return Scaffold(
        backgroundColor: AppColors.bgLightGrey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18), onPressed: () => context.pop()),
          title: const Text('No Active Job'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.box_remove, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              const Text('No job selected.', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Create New Job',
                onPressed: () => context.push('/tech-create-job'),
                icon: Iconsax.add,
                width: 200,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Job Card Details', style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        actions: [
          // Edit/Save toggle
          IconButton(
            icon: Icon(_isEditing ? Icons.check_rounded : Icons.edit_note_rounded, color: AppColors.primaryBlue),
            onPressed: _isSaving ? null : _toggleEdit,
          ),
          // Export report
          IconButton(
            icon: const Icon(Iconsax.export, color: AppColors.primaryBlue),
            onPressed: () {
              HapticFeedback.lightImpact();
              NavHelpers.showSuccess(context, 'Report generated successfully!');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ─── Status Banner ───
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(jobState.id, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800)),
                          Text('Estimated Completion: ${jobState.estimatedCompletion}', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (jobState.status == 'COMPLETED' ? AppColors.successGreen : AppColors.warningAmber).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(jobState.status, style: GoogleFonts.outfit(color: jobState.status == 'COMPLETED' ? AppColors.successGreen : AppColors.warningAmber, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: jobState.progress,
                    backgroundColor: AppColors.bgLightGrey,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                    minHeight: 8,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // ─── Vehicle Details (Editable) ───
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.15), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                        child: const Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_isEditing)
                              TextField(
                                controller: _modelController,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 6),
                                  border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                                  hintText: 'Vehicle Model',
                                  hintStyle: TextStyle(color: Colors.white38),
                                ),
                              )
                            else
                              Text(jobState.vehicleModel, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
                            const SizedBox(height: 6),
                            if (_isEditing)
                              TextField(
                                controller: _plateController,
                                style: const TextStyle(fontSize: 12, color: Colors.white70),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                                  border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                                  hintText: 'Reg No.',
                                  hintStyle: TextStyle(color: Colors.white38),
                                ),
                              )
                            else
                              Text('${jobState.vehiclePlate} • Petrol', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                          ],
                        ),
                      ),
                      if (_isEditing && _isSaving)
                        const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      else if (_isEditing)
                        IconButton(
                          onPressed: _saveVehicleDetails,
                          icon: const Icon(Icons.save_rounded, color: Colors.greenAccent),
                        ),
                    ],
                  ),
                ],
              ),
            ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // ─── Vehicle Location Map (Static & Clickable) ───
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                // Navigate to a full tracking screen or larger map if needed
                context.push('/live-tracking');
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: const AbsorbPointer(
                  child: LiveMapWidget(height: 180, showLiveIndicator: true),
                ),
              ),
            ).animate(delay: 200.ms).fadeIn().scale(),

            const SizedBox(height: 16),

            // ─── Service Checklist ───
            _buildSectionHeader('Service Checklist'),
            const SizedBox(height: 12),
            _buildGroupedChecklist(ref, jobState),

            const SizedBox(height: 24),

            // ─── Parts & Lubricants ───
            _buildSectionHeader('Parts & Lubricants'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  ...jobState.parts.map((part) => _buildPartItem(part.name, part.qty, part.isFound)),
                  const Divider(height: 32),
                  CustomButton(
                    label: 'ADD SPARE PART',
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.push('/tech-spare-parts');
                    },
                    isOutlined: true,
                    icon: Icons.add_rounded,
                    height: 44,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ─── Action Buttons ───
            if (jobState.status == 'CREATED') ...[
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'ACCEPT JOB',
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        ref.read(technicianProvider.notifier).acceptJob();
                        NavHelpers.showSuccess(context, 'Job accepted! You can now start work.');
                      },
                      backgroundColor: AppColors.primaryBlue,
                      height: 52,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (jobState.status == 'ACCEPTED') ...[
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'START JOB',
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        ref.read(technicianProvider.notifier).startJob();
                        NavHelpers.showSuccess(context, 'Job started! Complete the checklist.');
                      },
                      backgroundColor: const Color(0xFF1A237E),
                      icon: Icons.play_arrow_rounded,
                      height: 52,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: jobState.status == 'COMPLETED' ? 'JOB FINISHED ✓' : 'FINISH JOB',
                    onPressed: jobState.status == 'COMPLETED' ? null : () {
                      HapticFeedback.heavyImpact();
                      ref.read(technicianProvider.notifier).finishJob();
                      NavHelpers.showSuccess(context, 'Job marked as complete! Pending QA check.');
                    },
                    backgroundColor: jobState.status == 'COMPLETED' ? AppColors.textMuted : AppColors.successGreen,
                    height: 52,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildGroupedChecklist(WidgetRef ref, TechnicianJob job) {
    return Column(
      children: List.generate(job.checklist.length, (index) {
        final item = job.checklist[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: CheckboxListTile(
            value: item.isDone,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              ref.read(technicianProvider.notifier).toggleChecklistItem(index);
            },
            title: Text(
              item.task,
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, decoration: item.isDone ? TextDecoration.lineThrough : null),
            ),
            subtitle: Text(item.category, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
            activeColor: AppColors.successGreen,
            checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            secondary: Icon(
              item.isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: item.isDone ? AppColors.successGreen : AppColors.textMuted,
            ),
          ),
        ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.05, end: 0);
      }),
    );
  }

  Widget _buildPartItem(String name, String qty, bool isFound) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
              Text('Qty: $qty', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          isFound
            ? const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 20)
            : const Icon(Icons.pending_rounded, color: AppColors.warningAmber, size: 20),
        ],
      ),
    );
  }
}
