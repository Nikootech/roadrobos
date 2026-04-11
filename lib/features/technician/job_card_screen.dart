import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import 'technician_provider.dart';

/// Job Card Details for Technician matching Figma Screen [88 & 10]
class TechnicianJobCardScreen extends ConsumerStatefulWidget {
  const TechnicianJobCardScreen({super.key});

  @override
  ConsumerState<TechnicianJobCardScreen> createState() => _TechnicianJobCardScreenState();
}

class _TechnicianJobCardScreenState extends ConsumerState<TechnicianJobCardScreen> {
  final List<XFile> _jobPhotos = [];
  final ImagePicker _picker = ImagePicker();
  
  bool _isEditing = false;
  late TextEditingController _modelController;
  late TextEditingController _plateController;

  @override
  void initState() {
    super.initState();
    final activeJob = ref.read(selectedJobProvider);
    _modelController = TextEditingController(text: activeJob?.vehicleModel ?? '');
    _plateController = TextEditingController(text: activeJob?.vehiclePlate ?? '');
  }

  @override
  void dispose() {
    _modelController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _jobPhotos.add(image));
    }
  }

  void _saveVehicleDetails() {
    final activeJob = ref.read(selectedJobProvider);
    if (activeJob != null) {
      ref.read(technicianProvider.notifier).updateJob(
        activeJob.copyWith(
          vehicleModel: _modelController.text,
          vehiclePlate: _plateController.text,
        ),
      );
    }
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vehicle details updated!'), backgroundColor: AppColors.successGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeJob = ref.watch(selectedJobProvider);
    
    if (activeJob == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('No Active Job')),
        body: const Center(child: Text('Please select or create a job first.')),
      );
    }

    final totalTasks = activeJob.checklist.length;
    final completedTasks = activeJob.checklist.where((item) => item.isDone).length;
    final progress = activeJob.progress;

    // Group checklist by category
    final Map<String, List<ChecklistItem>> groupedChecklist = {};
    for (var item in activeJob.checklist) {
      groupedChecklist.putIfAbsent(item.category, () => []).add(item);
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
        title: Text('${activeJob.id} Execution', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check_rounded : Icons.edit_note_rounded, color: AppColors.primaryBlue),
            onPressed: () {
              if (_isEditing) {
                _saveVehicleDetails();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
            children: [
               // Vehicle Context (Interactive)
               Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.deepNavy, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                      child: const Icon(Icons.directions_car_filled_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isEditing)
                            TextField(
                              controller: _modelController,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 4),
                                border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                                labelStyle: TextStyle(color: Colors.white70, fontSize: 10),
                              ),
                            )
                          else
                            Text(activeJob.vehicleModel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                          
                          const SizedBox(height: 4),
                          
                          if (_isEditing)
                            TextField(
                              controller: _plateController,
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 4),
                                border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                                labelStyle: TextStyle(color: Colors.white70, fontSize: 10),
                              ),
                            )
                          else
                            Text('${activeJob.vehiclePlate} • Petrol', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    )
                  ],
                ),
               ).animate().fadeIn().slideY(begin: -0.1, end: 0),
               
               const SizedBox(height: 24),
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   const Text('Checklist Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                   Text('$completedTasks/$totalTasks Completed', style: const TextStyle(fontSize: 13, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                 ],
               ),
               const SizedBox(height: 12),
               LinearProgressIndicator(
                 value: progress,
                 backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                 color: AppColors.primaryBlue,
                 minHeight: 8,
                 borderRadius: BorderRadius.circular(4),
               ).animate(target: progress).shimmer(),

               const SizedBox(height: 24),

               // Checklists
               ...groupedChecklist.entries.map((entry) {
                 return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(6)),
                        child: Text(entry.key.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                        child: Column(
                          children: entry.value.map((item) {
                            final originalIndex = activeJob.checklist.indexOf(item);
                            return CheckboxListTile(
                              title: Text(item.task, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, decoration: item.isDone ? TextDecoration.lineThrough : null, color: item.isDone ? AppColors.textSecondary : AppColors.textPrimary)),
                              value: item.isDone,
                              activeColor: AppColors.successGreen,
                              checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (bool? val) {
                                ref.read(technicianProvider.notifier).toggleChecklistItem(activeJob.id, originalIndex);
                              },
                            );
                          }).toList(),
                        ),
                      )
                    ],
                 ).animate().fadeIn().slideX(begin: 0.1, end: 0);
               }),

               const SizedBox(height: 12),
               const Text('Job Photos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
               const SizedBox(height: 16),
               SizedBox(
                 height: 100,
                 child: ListView.separated(
                   scrollDirection: Axis.horizontal,
                   itemCount: _jobPhotos.length + 1,
                   separatorBuilder: (_, __) => const SizedBox(width: 12),
                   itemBuilder: (context, index) {
                     if (index == _jobPhotos.length) {
                       return GestureDetector(
                         onTap: _addPhoto,
                         child: Container(
                           width: 100,
                           decoration: BoxDecoration(
                             color: AppColors.bgLightGrey,
                             borderRadius: BorderRadius.circular(16),
                             border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                           ),
                           child: const Icon(Icons.add_a_photo_rounded, color: AppColors.textSecondary),
                         ),
                       );
                     }
                     return ClipRRect(
                       borderRadius: BorderRadius.circular(16),
                       child: Image.file(
                         File(_jobPhotos[index].path),
                         width: 100,
                         height: 100,
                         fit: BoxFit.cover,
                       ),
                     );
                   },
                 ),
               ),
            ],
          ),

          // Action bottom bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
              ),
              child: CustomButton(
                label: progress >= 1.0 ? 'FINISH JOB' : 'SAVE DRAFT',
                backgroundColor: progress >= 1.0 ? AppColors.successGreen : AppColors.deepNavy,
                onPressed: () { 
                  if(progress >= 1.0) {
                    ref.read(technicianProvider.notifier).finishJob(activeJob.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Job completed successfully!'), backgroundColor: AppColors.successGreen),
                    );
                    context.pop(); 
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Draft saved!'), backgroundColor: AppColors.primaryBlue),
                    );
                    context.pop();
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
