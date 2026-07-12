import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Choose Language',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 16),
            child: Text('SELECT PREFERRED LANGUAGE',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2)),
          ),
          ...[
            'English',
            'Hindi (हिन्दी)',
            'Telugu (తెలుగు)',
            'Marathi (मराठी)',
            'Tamil (தமிழ்)',
            'Kannada (ಕನ್ನಡ)'
          ].map((l) {
            final isSelected = _selected == l;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color:
                        isSelected ? AppColors.primaryBlue : Colors.transparent,
                    width: 2),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: ListTile(
                onTap: () => setState(() => _selected = l),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryBlue.withValues(alpha: 0.1)
                          : AppColors.bgLightGrey,
                      shape: BoxShape.circle),
                  child: Icon(Icons.language_rounded,
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.textMuted,
                      size: 20),
                ),
                title: Text(l,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.textPrimary)),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.primaryBlue, size: 22)
                        .animate()
                        .scale()
                    : Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.border, width: 2))),
              ),
            ).animate().fadeIn().slideX(begin: 0.05, end: 0);
          }),
        ],
      ),
    );
  }
}
