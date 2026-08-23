import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

/// Read-only audit/analytics section for auditor and analyst roles.
class AuditDashboardSection extends StatelessWidget {
  const AuditDashboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Audit & Compliance',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF475569).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'READ ONLY',
                style: GoogleFonts.outfit(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF475569),
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              _AuditRow(
                icon: Iconsax.document_text,
                label: 'Recent Audit Entries',
                value: 'View',
                color: const Color(0xFF475569),
                onTap: () => context.push('/admin/audit-logs'),
              ),
              const Divider(height: 1),
              const _AuditRow(
                icon: Iconsax.shield_tick,
                label: 'Compliance Score',
                value: '--',
                color: Color(0xFF059669),
                onTap: null,
              ),
              const Divider(height: 1),
              _AuditRow(
                icon: Iconsax.chart_21,
                label: 'Platform Analytics',
                value: 'View',
                color: const Color(0xFF4F46E5),
                onTap: () => context.push('/admin-revenue-referral'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: const Color(0xFF475569).withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => context.push('/admin/audit-logs'),
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Iconsax.document_text,
                      size: 18, color: Color(0xFF475569)),
                  SizedBox(width: 12),
                  Text(
                    'View Full Audit Trail',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF475569),
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: Color(0xFF475569)),
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.08, end: 0);
  }
}

class _AuditRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _AuditRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 15),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: onTap != null ? color : AppColors.textPrimary,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  size: 14, color: AppColors.textMuted),
            ],
          ],
        ),
      ),
    );
  }
}
