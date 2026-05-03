import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/app_service.dart';
import '../theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
              isAr ? 'سياسة الخصوصية' : 'Privacy Policy',
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
                    icon: Icons.data_usage_rounded,
                    iconColor: const Color(0xFF6366F1),
                    title: isAr ? 'جمع البيانات' : 'Data Collection',
                    body: isAr
                        ? 'لا نجمع أي بيانات شخصية'
                        : 'We do not collect any personal data',
                    colors: c,
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    icon: Icons.storage_rounded,
                    iconColor: const Color(0xFF10B981),
                    title: isAr ? 'التخزين المحلي' : 'Local Storage',
                    body: isAr
                        ? 'المفضلات والإعدادات تُحفظ محلياً فقط على جهازك'
                        : 'Favorites and settings are saved locally on your device only',
                    colors: c,
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    icon: Icons.open_in_new_rounded,
                    iconColor: const Color(0xFF06B6D4),
                    title: isAr ? 'روابط خارجية' : 'External Links',
                    body: isAr
                        ? 'التطبيق يفتح روابط خارجية في المتصفح'
                        : 'The app opens external links in the browser',
                    colors: c,
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    icon: Icons.mail_outline_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: isAr ? 'تواصل معنا' : 'Contact Us',
                    body: isAr
                        ? 'للاستفسارات: support@aitoolshub.app'
                        : 'For inquiries: support@aitoolshub.app',
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
