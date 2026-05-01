import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/app_service.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangService>();
    final theme = context.watch<ThemeService>();
    final isAr = lang.isArabic;
    final scheme = AppColors.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        _sectionTitle(isAr ? 'التفضيلات' : 'Preferences', isAr, scheme),
        const SizedBox(height: 10),

        // Language
        _SettingsCard(
          scheme: scheme,
          children: [
            _SettingsTile(
              scheme: scheme,
              icon: Icons.language_rounded,
              iconColor: const Color(0xFF6366F1),
              title: isAr ? 'اللغة' : 'Language',
              subtitle: isAr ? 'العربية' : 'English',
              trailing: Switch.adaptive(
                value: isAr,
                activeThumbColor: const Color(0xFF6366F1),
                activeTrackColor: const Color(0xFF6366F1).withValues(alpha: 0.5),
                onChanged: (_) => lang.toggle(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Theme
        _SettingsCard(
          scheme: scheme,
          children: [
            _SettingsTile(
              scheme: scheme,
              icon: Icons.palette_rounded,
              iconColor: const Color(0xFF8B5CF6),
              title: isAr ? 'المظهر' : 'Appearance',
              subtitle: _themeName(theme.mode, isAr),
              trailing: const SizedBox.shrink(),
            ),
            Divider(height: 1, color: scheme.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                children: [
                  _ThemeChip(
                    label: isAr ? 'فاتح' : 'Light',
                    icon: Icons.wb_sunny_rounded,
                    selected: theme.mode == ThemeMode.light,
                    color: const Color(0xFFF59E0B),
                    scheme: scheme,
                    onTap: () => theme.setMode(ThemeMode.light),
                  ),
                  const SizedBox(width: 8),
                  _ThemeChip(
                    label: isAr ? 'داكن' : 'Dark',
                    icon: Icons.nightlight_rounded,
                    selected: theme.mode == ThemeMode.dark,
                    color: const Color(0xFF6366F1),
                    scheme: scheme,
                    onTap: () => theme.setMode(ThemeMode.dark),
                  ),
                  const SizedBox(width: 8),
                  _ThemeChip(
                    label: isAr ? 'تلقائي' : 'System',
                    icon: Icons.settings_brightness_rounded,
                    selected: theme.mode == ThemeMode.system,
                    color: const Color(0xFF10B981),
                    scheme: scheme,
                    onTap: () => theme.setMode(ThemeMode.system),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        _sectionTitle(isAr ? 'التطبيق' : 'App Info', isAr, scheme),
        const SizedBox(height: 10),

        _SettingsCard(
          scheme: scheme,
          children: [
            _SettingsTile(
              scheme: scheme,
              icon: Icons.info_outline_rounded,
              iconColor: const Color(0xFF06B6D4),
              title: isAr ? 'الإصدار' : 'Version',
              subtitle: '1.0.0',
            ),
            Divider(height: 1, color: scheme.border),
            _SettingsTile(
              scheme: scheme,
              icon: Icons.auto_awesome_rounded,
              iconColor: const Color(0xFFF59E0B),
              title: isAr ? 'عدد الأدوات' : 'Total Tools',
              subtitle: '100',
            ),
            Divider(height: 1, color: scheme.border),
            _SettingsTile(
              scheme: scheme,
              icon: Icons.person_rounded,
              iconColor: const Color(0xFF10B981),
              title: isAr ? 'المطور' : 'Developer',
              subtitle: 'Saad',
            ),
          ],
        ),

        const SizedBox(height: 12),

        _SettingsCard(
          scheme: scheme,
          children: [
            _SettingsTile(
              scheme: scheme,
              icon: Icons.privacy_tip_outlined,
              iconColor: const Color(0xFF3B82F6),
              title: isAr ? 'سياسة الخصوصية' : 'Privacy Policy',
              subtitle: isAr ? 'اطّلع على سياسة الخصوصية' : 'View our privacy policy',
              trailing: Icon(Icons.chevron_right_rounded,
                  color: scheme.textTertiary, size: 20),
              onTap: () => _showPlaceholder(
                context, scheme,
                isAr ? 'سياسة الخصوصية' : 'Privacy Policy',
                isAr
                    ? 'سياسة الخصوصية ستكون متاحة قريباً.'
                    : 'Privacy policy will be available soon.',
              ),
            ),
            Divider(height: 1, color: scheme.border),
            _SettingsTile(
              scheme: scheme,
              icon: Icons.description_outlined,
              iconColor: const Color(0xFF8B5CF6),
              title: isAr ? 'شروط الاستخدام' : 'Terms of Use',
              subtitle: isAr ? 'اقرأ شروط الاستخدام' : 'Read terms of use',
              trailing: Icon(Icons.chevron_right_rounded,
                  color: scheme.textTertiary, size: 20),
              onTap: () => _showPlaceholder(
                context, scheme,
                isAr ? 'شروط الاستخدام' : 'Terms of Use',
                isAr
                    ? 'شروط الاستخدام ستكون متاحة قريباً.'
                    : 'Terms of use will be available soon.',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _SettingsCard(
          scheme: scheme,
          children: [
            _SettingsTile(
              scheme: scheme,
              icon: Icons.star_outline_rounded,
              iconColor: const Color(0xFFF59E0B),
              title: isAr ? 'قيّم التطبيق' : 'Rate the App',
              subtitle: isAr ? 'ساعدنا بتقييمك على المتجر' : 'Help us with a store review',
              trailing: Icon(Icons.chevron_right_rounded,
                  color: scheme.textTertiary, size: 20),
              onTap: () => _showPlaceholder(
                context, scheme,
                isAr ? 'تقييم التطبيق' : 'Rate App',
                isAr
                    ? 'رابط المتجر سيكون متاحاً قريباً.'
                    : 'Store link will be available soon.',
              ),
            ),
            Divider(height: 1, color: scheme.border),
            _SettingsTile(
              scheme: scheme,
              icon: Icons.share_rounded,
              iconColor: const Color(0xFF10B981),
              title: isAr ? 'شارك التطبيق' : 'Share App',
              subtitle: isAr ? 'شارك مع أصدقائك' : 'Share with your friends',
              trailing: Icon(Icons.chevron_right_rounded,
                  color: scheme.textTertiary, size: 20),
              onTap: () => Share.share(
                isAr
                    ? '🤖 تطبيق AI Tools Hub — أفضل 100 أداة ذكاء اصطناعي في مكان واحد!\nجرّبه الآن.'
                    : '🤖 AI Tools Hub — 100 AI tools in one place!\nTry it now.',
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),
        Center(
          child: Text(
            isAr ? 'AI Tools Hub v1.0.0\nصنع بـ ❤️' : 'AI Tools Hub v1.0.0\nMade with ❤️',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: scheme.textTertiary,
              height: 1.8,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _sectionTitle(String title, bool isAr, AppColors scheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 2),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF6366F1),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _themeName(ThemeMode mode, bool isAr) {
    switch (mode) {
      case ThemeMode.light:
        return isAr ? 'فاتح' : 'Light';
      case ThemeMode.dark:
        return isAr ? 'داكن' : 'Dark';
      case ThemeMode.system:
        return isAr ? 'تلقائي (النظام)' : 'System Default';
    }
  }

  void _showPlaceholder(
      BuildContext context, AppColors scheme, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: scheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: GoogleFonts.cairo(
                fontWeight: FontWeight.w700, color: scheme.textPrimary)),
        content: Text(message,
            style: GoogleFonts.cairo(color: scheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK',
                style: GoogleFonts.cairo(color: const Color(0xFF6366F1))),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable widgets ─────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final AppColors scheme;
  final List<Widget> children;

  const _SettingsCard({required this.scheme, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.border),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final AppColors scheme;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.scheme,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
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
                      fontWeight: FontWeight.w600,
                      color: scheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                        fontSize: 12, color: scheme.textTertiary),
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final AppColors scheme;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.scheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.15)
                : scheme.bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? color : scheme.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: selected ? color : scheme.textTertiary),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? color : scheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
