import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/app_service.dart';
import '../theme/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LangService>().isArabic;
    final c    = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: c.surface,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              isAr ? 'شروط الاستخدام' : 'Terms of Use',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Section(
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: const Color(0xFF6366F1),
                    title: isAr ? 'قبول الشروط' : 'Acceptance',
                    body: isAr
                        ? 'باستخدام التطبيق توافق على هذه الشروط'
                        : 'By using the app you agree to these terms',
                    colors: c,
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    icon: Icons.person_outline_rounded,
                    iconColor: const Color(0xFF10B981),
                    title: isAr ? 'الاستخدام المسموح' : 'Permitted Use',
                    body: isAr
                        ? 'للاستخدام الشخصي فقط'
                        : 'For personal use only',
                    colors: c,
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    icon: Icons.info_outline_rounded,
                    iconColor: const Color(0xFF06B6D4),
                    title: isAr ? 'إخلاء المسؤولية' : 'Disclaimer',
                    body: isAr
                        ? 'المعلومات للأغراض التعليمية فقط'
                        : 'Information is for educational purposes only',
                    colors: c,
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    icon: Icons.edit_note_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: isAr ? 'التعديلات' : 'Changes',
                    body: isAr
                        ? 'نحتفظ بحق تعديل الشروط'
                        : 'We reserve the right to modify these terms',
                    colors: c,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final AppColors colors;

  const _Section({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: c.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
