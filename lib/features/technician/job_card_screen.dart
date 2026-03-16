import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';

/// Job Card Details for Technician matching Figma Screen [88 & 10]
class TechnicianJobCardScreen extends StatefulWidget {
  const TechnicianJobCardScreen({super.key});

  @override
  State<TechnicianJobCardScreen> createState() => _TechnicianJobCardScreenState();
}

class _TechnicianJobCardScreenState extends State<TechnicianJobCardScreen> {
  final Map<String, List<Map<String, dynamic>>> _checklists = {
    'Engine & Transmission': [
      {'task': 'Check Engine Oil Level', 'done': true},
      {'task': 'Inspect Coolant Level', 'done': false},
      {'task': 'Inspect Drive Belts', 'done': false},
    ],
    'Brakes & Tyres': [
      {'task': 'Check Brake Pads (Front)', 'done': false},
      {'task': 'Check Brake Pads (Rear)', 'done': false},
      {'task': 'Verify Tyre Pressure & Tread', 'done': false},
    ]
  };

  final List<XFile> _jobPhotos = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _addPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _jobPhotos.add(image));
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalTasks = _checklists.values.fold(0, (sum, list) => sum + list.length);
    int completedTasks = _checklists.values.fold(0, (sum, list) => sum + list.where((item) => item['done']).length);
    double progress = totalTasks > 0 ? completedTasks / totalTasks : 0;

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('JOB-004 Execution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
            children: [
               // Vehicle Context
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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Maruti Baleno', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                        SizedBox(height: 4),
                        Text('MH 01 ZX 9876 • Petrol', style: TextStyle(fontSize: 12, color: Colors.white70)),
                      ],
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
                 backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                 color: AppColors.primaryBlue,
                 minHeight: 8,
                 borderRadius: BorderRadius.circular(4),
               ).animate(target: progress).shimmer(),

               const SizedBox(height: 24),

               // Checklists
               ..._checklists.entries.map((category) {
                 return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(6)),
                        child: Text(category.key.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                        child: Column(
                          children: category.value.map((task) {
                            return CheckboxListTile(
                              title: Text(task['task'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, decoration: task['done'] ? TextDecoration.lineThrough : null, color: task['done'] ? AppColors.textSecondary : AppColors.textPrimary)),
                              value: task['done'],
                              activeColor: AppColors.successGreen,
                              checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (bool? val) {
                                setState(() => task['done'] = val ?? false);
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
                label: progress == 1.0 ? 'MARK JOB COMPLETE' : 'SAVE DRAFT',
                backgroundColor: progress == 1.0 ? AppColors.successGreen : AppColors.deepNavy,
                onPressed: () { if(progress == 1.0) context.pop(); },
              ),
            ),
          )
        ],
      ),
    );
  }
}

