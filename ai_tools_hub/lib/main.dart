import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/favorites_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/recent_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/tool_detail_screen.dart';
import 'screens/tools_list_screen.dart';
import 'services/app_service.dart';
import 'theme/app_colors.dart';
import 'widgets/hub_app_bar.dart';
import 'models/ai_tool.dart';

// ─── Themes ───────────────────────────────────────────────────────────────────
ThemeData _darkTheme() {
  final base = ThemeData.dark();
  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFF0A0E27),
    colorScheme: const ColorScheme.dark(
      primary: kPrimary,
      secondary: kSecondary,
      surface: Color(0xFF1A1F3A),
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: GoogleFonts.cairoTextTheme(base.textTheme)
        .apply(bodyColor: Colors.white, displayColor: Colors.white),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF131729),
      indicatorColor: kPrimary.withValues(alpha: 0.2),
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
        color: s.contains(WidgetState.selected) ? kPrimary : const Color(0x61FFFFFF),
      )),
      labelTextStyle: WidgetStateProperty.resolveWith((s) {
        final sel = s.contains(WidgetState.selected);
        return GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: sel ? kPrimary : const Color(0x61FFFFFF),
        );
      }),
    ),
  );
}

ThemeData _lightTheme() {
  final base = ThemeData.light();
  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFFF3F4F6),
    colorScheme: const ColorScheme.light(
      primary: kPrimary,
      secondary: kSecondary,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSurface: Color(0xFF111827),
    ),
    textTheme: GoogleFonts.cairoTextTheme(base.textTheme).apply(
      bodyColor: const Color(0xFF111827),
      displayColor: const Color(0xFF111827),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: kPrimary.withValues(alpha: 0.12),
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
        color: s.contains(WidgetState.selected) ? kPrimary : const Color(0xFF9CA3AF),
      )),
      labelTextStyle: WidgetStateProperty.resolveWith((s) {
        final sel = s.contains(WidgetState.selected);
        return GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: sel ? kPrimary : const Color(0xFF9CA3AF),
        );
      }),
    ),
    dividerColor: const Color(0xFFE5E7EB),
    cardColor: Colors.white,
  );
}

// ─── Entry ────────────────────────────────────────────────────────────────────
void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('onboarding_seen') ?? false;
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LangService(prefs)),
      ChangeNotifierProvider(create: (_) => FavService(prefs)),
      ChangeNotifierProvider(create: (_) => ThemeService(prefs)),
      ChangeNotifierProvider(create: (_) => ViewCountService(prefs)),
      ChangeNotifierProvider(create: (_) => RecentService(prefs)),
    ],
    child: MyApp(seenOnboarding: seenOnboarding),
  ));
  FlutterNativeSplash.remove();
}

// ─── App ──────────────────────────────────────────────────────────────────────
class MyApp extends StatefulWidget {
  final bool seenOnboarding;
  const MyApp({super.key, required this.seenOnboarding});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navKey = GlobalKey<NavigatorState>();

  void _onOnboardingDone() {
    _navKey.currentState?.pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (ctx2, a1, a2) => const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (ctx2, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LangService, ThemeService>(
      builder: (ctx, lang, themeService, _) => MaterialApp(
        title: 'AI Tools Hub',
        debugShowCheckedModeBanner: false,
        navigatorKey: _navKey,
        themeMode: themeService.mode,
        theme: _lightTheme(),
        darkTheme: _darkTheme(),
        builder: (bctx, navWidget) => Directionality(
          textDirection:
              lang.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: navWidget!,
        ),
        home: widget.seenOnboarding
            ? const HomeScreen()
            : OnboardingScreen(onDone: _onOnboardingDone),
      ),
    );
  }
}

// ─── Home Screen ──────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  void _openTool(AiTool tool) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (ctx2, a1, a2) => ToolDetailScreen(tool: tool),
        transitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (ctx2, anim, a2, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangService>();
    final isAr = lang.isArabic;
    final c    = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: HubAppBar(isArabic: isAr, onToggleLang: lang.toggle, colors: c),
      body: IndexedStack(
        index: _tab,
        children: [
          const ToolsListScreen(),
          const FavoritesScreen(),
          RecentScreen(onTap: _openTool),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _buildNav(isAr, c),
    );
  }

  Widget _buildNav(bool isAr, AppColors c) {
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border, width: 1)),
      ),
      child: NavigationBar(
        selectedIndex: _tab,
        backgroundColor: Colors.transparent,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard_rounded),
            label: isAr ? 'الأدوات' : 'Tools',
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_outline_rounded),
            selectedIcon: const Icon(Icons.favorite_rounded),
            label: isAr ? 'المفضلة' : 'Favorites',
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history_rounded),
            label: isAr ? 'الأخيرة' : 'Recent',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: isAr ? 'الإعدادات' : 'Settings',
          ),
        ],
      ),
    );
  }
}
