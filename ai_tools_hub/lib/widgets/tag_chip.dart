import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

Color tagColor(String tag) {
  if (tag == 'Free' || tag == 'مجاني') return const Color(0xFF10B981);
  if (tag == 'Free Plan' || tag == 'نسخة مجانية') return const Color(0xFF059669);
  if (tag == 'Top Rated' || tag == 'الأعلى تقييماً') return const Color(0xFFF59E0B);
  if (tag == 'Open Source' || tag == 'مفتوح المصدر') return const Color(0xFF6366F1);
  if (tag == 'Mobile' || tag == 'موبايل') return const Color(0xFF06B6D4);
  if (tag == 'Enterprise' || tag == 'مؤسسي') return const Color(0xFF8B5CF6);
  if (tag == 'API') return const Color(0xFFEC4899);
  if (tag == 'IDE') return const Color(0xFF10B981);
  if (tag == 'Privacy' || tag == 'خصوصية') return const Color(0xFF3B82F6);
  if (tag == 'No-Code' || tag == 'بدون كود') return const Color(0xFFF97316);
  if (tag == 'Collaboration' || tag == 'تعاون') return const Color(0xFF84CC16);
  if (tag == 'Multi-Model' || tag == 'متعدد النماذج') return const Color(0xFFEF4444);
  if (tag == 'SEO') return const Color(0xFF0EA5E9);
  if (tag == 'Meetings' || tag == 'اجتماعات') return const Color(0xFF14B8A6);
  if (tag == 'CRM') return const Color(0xFFF97316);
  if (tag == 'Cloud' || tag == 'سحابي') return const Color(0xFF38BDF8);
  return const Color(0xFF6B7280);
}

class TagChip extends StatelessWidget {
  final String label;
  final AppColors colors;

  const TagChip({super.key, required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    final color = tagColor(label);
    final c     = colors;
    return Container(
      margin: const EdgeInsets.only(right: 6, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: c.isDark ? 0.15 : 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
