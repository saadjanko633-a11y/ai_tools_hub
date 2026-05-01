import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  static const _pages = [
    _OPage(
      emoji: '🤖',
      titleAr: 'اكتشف عالم الذكاء الاصطناعي',
      titleEn: 'Discover the AI World',
      descAr: 'تصفح أكثر من 100 أداة ذكاء اصطناعي في مكان واحد',
      descEn: 'Browse 100+ AI tools all in one place',
    ),
    _OPage(
      emoji: '⭐',
      titleAr: 'احفظ أدواتك المفضلة',
      titleEn: 'Save Your Favorites',
      descAr: 'نظّم أدواتك المفضلة واستخدمها بسهولة في أي وقت',
      descEn: 'Organize your favorite tools and access them anytime',
    ),
    _OPage(
      emoji: '🚀',
      titleAr: 'ابدأ الآن!',
      titleEn: 'Get Started!',
      descAr: 'كل أدوات الذكاء الاصطناعي بين يديك — ابدأ استكشافها الآن',
      descEn: 'All AI tools at your fingertips — start exploring now',
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_seen', true);
    } catch (_) {}
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextButton(
                  onPressed: _complete,
                  child: Text(
                    isAr ? 'تخطى' : 'Skip',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: const Color(0x80FFFFFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return _PageContent(
                    emoji: p.emoji,
                    title: isAr ? p.titleAr : p.titleEn,
                    desc: isAr ? p.descAr : p.descEn,
                  );
                },
              ),
            ),
            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 24),
                  width: _page == i ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i ? kPrimary : const Color(0xFF2A2F52),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            // Action button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimary, kSecondary],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (isLast) {
                        _complete();
                      } else {
                        _ctrl.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isLast
                          ? (isAr ? '🚀 ابدأ' : '🚀 Start')
                          : (isAr ? 'التالي ←' : 'Next →'),
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data class ───────────────────────────────────────────────────────────────
class _OPage {
  final String emoji, titleAr, titleEn, descAr, descEn;
  const _OPage({
    required this.emoji,
    required this.titleAr,
    required this.titleEn,
    required this.descAr,
    required this.descEn,
  });
}

// ─── Page content ─────────────────────────────────────────────────────────────
class _PageContent extends StatelessWidget {
  final String emoji, title, desc;
  const _PageContent({required this.emoji, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: kPrimary.withValues(alpha: 0.25), width: 1.5),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 72)),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: const Color(0xB3FFFFFF),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
