import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data/tools_data.dart';
import 'models/ai_tool.dart';
import 'screens/settings_screen.dart';
import 'services/app_service.dart';

// ─── Theme-independent constants ──────────────────────────────────────────────
const kPrimary   = Color(0xFF6366F1);
const kSecondary = Color(0xFF8B5CF6);

// ─── Dynamic color helper ─────────────────────────────────────────────────────
class AppColors {
  final Color bg;
  final Color card;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final bool isDark;

  const AppColors._({
    required this.bg,
    required this.card,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.isDark,
  });

  static AppColors of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AppColors._(
      bg:            dark ? const Color(0xFF0A0E27) : const Color(0xFFF3F4F6),
      card:          dark ? const Color(0xFF1A1F3A) : Colors.white,
      surface:       dark ? const Color(0xFF131729) : Colors.white,
      border:        dark ? const Color(0xFF2A2F52) : const Color(0xFFE5E7EB),
      textPrimary:   dark ? Colors.white             : const Color(0xFF111827),
      textSecondary: dark ? const Color(0xB3FFFFFF)  : const Color(0xFF374151),
      textTertiary:  dark ? const Color(0x61FFFFFF)  : const Color(0xFF9CA3AF),
      isDark: dark,
    );
  }
}

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
          fontSize: 12,
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
          fontSize: 12,
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
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LangService(prefs)),
      ChangeNotifierProvider(create: (_) => FavService(prefs)),
      ChangeNotifierProvider(create: (_) => ThemeService(prefs)),
    ],
    child: const MyApp(),
  ));
  FlutterNativeSplash.remove();
}

// ─── App ──────────────────────────────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LangService, ThemeService>(
      builder: (context, lang, themeService, child) => MaterialApp(
        title: 'AI Tools Hub',
        debugShowCheckedModeBanner: false,
        themeMode: themeService.mode,
        theme: _lightTheme(),
        darkTheme: _darkTheme(),
        builder: (ctx, widget) => Directionality(
          textDirection:
              lang.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: widget!,
        ),
        home: const HomeScreen(),
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

  @override
  Widget build(BuildContext context) {
    final lang  = context.watch<LangService>();
    final isAr  = lang.isArabic;
    final c     = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: _HubAppBar(isArabic: isAr, onToggleLang: lang.toggle, colors: c),
      body: IndexedStack(
        index: _tab,
        children: const [ToolsListScreen(), FavoritesScreen(), SettingsScreen()],
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
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: isAr ? 'الإعدادات' : 'Settings',
          ),
        ],
      ),
    );
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────
class _HubAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isArabic;
  final VoidCallback onToggleLang;
  final AppColors colors;

  const _HubAppBar({
    required this.isArabic,
    required this.onToggleLang,
    required this.colors,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.border, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimary, kSecondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'AI Tools Hub',
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: c.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      isArabic ? 'أدوات الذكاء الاصطناعي' : 'AI Tools Directory',
                      style: GoogleFonts.cairo(
                          fontSize: 11, color: c.textTertiary),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onToggleLang,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: kPrimary.withValues(alpha: 0.35), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language_rounded, size: 14, color: kPrimary),
                      const SizedBox(width: 5),
                      Text(
                        isArabic ? 'EN' : 'عر',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: kPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sort Order ───────────────────────────────────────────────────────────────
enum SortOrder { defaultOrder, nameAsc, ratingDesc, newFirst }

// ─── Tools List Screen ────────────────────────────────────────────────────────
class ToolsListScreen extends StatefulWidget {
  const ToolsListScreen({super.key});

  @override
  State<ToolsListScreen> createState() => _ToolsListScreenState();
}

class _ToolsListScreenState extends State<ToolsListScreen> {
  final _searchCtrl = TextEditingController();
  String _query       = '';
  ToolCategory? _category;
  SortOrder _sortOrder = SortOrder.defaultOrder;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AiTool> _filtered(bool isAr) {
    var list = kAllTools.where((t) {
      final q = _query.toLowerCase();
      final nameMatch = t.localName(isAr).toLowerCase().contains(q);
      final descMatch = t.localDesc(isAr).toLowerCase().contains(q);
      final catMatch  = _category == null || t.category == _category;
      return (q.isEmpty || nameMatch || descMatch) && catMatch;
    }).toList();

    switch (_sortOrder) {
      case SortOrder.nameAsc:
        list.sort((a, b) => a.localName(isAr).compareTo(b.localName(isAr)));
      case SortOrder.ratingDesc:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case SortOrder.newFirst:
        list.sort((a, b) {
          if (a.isNew && !b.isNew) return -1;
          if (!a.isNew && b.isNew) return 1;
          return 0;
        });
      case SortOrder.defaultOrder:
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isAr   = context.watch<LangService>().isArabic;
    final c      = AppColors.of(context);
    final filtered = _filtered(isAr);

    return Column(
      children: [
        _buildSearchSection(isAr, c),
        Expanded(
          child: filtered.isEmpty
              ? _EmptyState(isArabic: isAr, colors: c)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => ToolCard(tool: filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(bool isAr, AppColors c) {
    return Container(
      color: c.surface,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildSearchField(isAr, c)),
              const SizedBox(width: 8),
              _buildSortButton(isAr, c),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _CategoryChip(
                  label: isAr ? 'الكل' : 'All',
                  icon: Icons.apps_rounded,
                  color: kPrimary,
                  selected: _category == null,
                  colors: c,
                  onTap: () => setState(() => _category = null),
                ),
                ...kCategories.map(
                  (cat) => _CategoryChip(
                    label: categoryLabel(cat, isAr),
                    icon: categoryIcon(cat),
                    color: categoryColor(cat),
                    selected: _category == cat,
                    colors: c,
                    onTap: () => setState(
                        () => _category = _category == cat ? null : cat),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(bool isAr, AppColors c) {
    return TextField(
      controller: _searchCtrl,
      onChanged: (v) => setState(() => _query = v),
      style: GoogleFonts.cairo(color: c.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: isAr ? 'ابحث عن أداة...' : 'Search tools...',
        hintStyle: GoogleFonts.cairo(color: c.textTertiary, fontSize: 14),
        prefixIcon:
            const Icon(Icons.search_rounded, color: kPrimary, size: 22),
        suffixIcon: _query.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.cancel_rounded,
                    color: c.textTertiary, size: 20),
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _query = '');
                },
              )
            : null,
        filled: true,
        fillColor: c.card,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSortButton(bool isAr, AppColors c) {
    final isActive = _sortOrder != SortOrder.defaultOrder;
    return PopupMenuButton<SortOrder>(
      tooltip: '',
      color: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: c.border),
      ),
      onSelected: (v) => setState(() => _sortOrder = v),
      itemBuilder: (_) => [
        _sortItem(SortOrder.defaultOrder, Icons.list_rounded,
            isAr ? 'الترتيب الافتراضي' : 'Default Order', c),
        _sortItem(SortOrder.nameAsc, Icons.sort_by_alpha_rounded,
            isAr ? 'بالاسم (أ-ي)' : 'By Name (A-Z)', c),
        _sortItem(SortOrder.ratingDesc, Icons.star_rounded,
            isAr ? 'بالتقييم (الأعلى)' : 'By Rating (Top)', c),
        _sortItem(SortOrder.newFirst, Icons.new_releases_rounded,
            isAr ? 'الأحدث أولاً' : 'Newest First', c),
      ],
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 52,
        decoration: BoxDecoration(
          color: isActive
              ? kPrimary.withValues(alpha: 0.15)
              : c.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? kPrimary.withValues(alpha: 0.5) : c.border,
            width: 1,
          ),
        ),
        child: Icon(
          Icons.sort_rounded,
          color: isActive ? kPrimary : c.textTertiary,
          size: 22,
        ),
      ),
    );
  }

  PopupMenuItem<SortOrder> _sortItem(
      SortOrder v, IconData icon, String label, AppColors c) {
    final sel = _sortOrder == v;
    return PopupMenuItem(
      value: v,
      child: Row(
        children: [
          Icon(icon, size: 18, color: sel ? kPrimary : c.textTertiary),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
              color: sel ? kPrimary : c.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category Chip ────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final AppColors colors;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: [color, color.withValues(alpha: 0.65)])
                : null,
            color: selected ? null : c.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: selected ? Colors.transparent : c.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 14, color: selected ? Colors.white : color),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : c.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isArabic;
  final AppColors colors;
  const _EmptyState({required this.isArabic, required this.colors});

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: c.border),
            ),
            child:
                const Icon(Icons.search_off_rounded, size: 40, color: kPrimary),
          ),
          const SizedBox(height: 20),
          Text(
            isArabic ? 'لا توجد نتائج' : 'No results found',
            style: GoogleFonts.cairo(
              color: c.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic ? 'جرب البحث بكلمات أخرى' : 'Try different keywords',
            style: GoogleFonts.cairo(color: c.textTertiary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─── Tag Color ────────────────────────────────────────────────────────────────
Color _tagColor(String tag) {
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

// ─── Tag Chip ─────────────────────────────────────────────────────────────────
class _TagChip extends StatelessWidget {
  final String label;
  final AppColors colors;

  const _TagChip({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    final color = _tagColor(label);
    final c = colors;
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

// ─── Tool Card ────────────────────────────────────────────────────────────────
class ToolCard extends StatelessWidget {
  final AiTool tool;
  const ToolCard({super.key, required this.tool});

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LangService>().isArabic;
    final c    = AppColors.of(context);
    final color = categoryColor(tool.category);
    final tags  = tool.displayTags(isAr);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withValues(alpha: 0.08),
          highlightColor: color.withValues(alpha: 0.04),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ToolDetailScreen(tool: tool)),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.border, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gradient top accent
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.2)],
                    ),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                  color: color.withValues(alpha: 0.25),
                                  width: 1),
                            ),
                            child: Center(
                              child: Text(
                                tool.icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Name + badges
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        tool.localName(isAr),
                                        style: GoogleFonts.cairo(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: c.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (tool.isNew) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFF59E0B),
                                              Color(0xFFF97316),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isAr ? '🆕 جديد' : '🆕 NEW',
                                          style: GoogleFonts.cairo(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    categoryLabel(tool.category, isAr),
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Favorite
                          Consumer<FavService>(
                            builder: (_, favs, _) {
                              final isFav = favs.isFav(tool.id);
                              return GestureDetector(
                                onTap: () => favs.toggle(tool.id),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: isFav
                                        ? Colors.red.withValues(alpha: 0.15)
                                        : c.bg,
                                    borderRadius: BorderRadius.circular(11),
                                    border: Border.all(
                                        color: isFav
                                            ? Colors.red.withValues(alpha: 0.3)
                                            : c.border,
                                        width: 1),
                                  ),
                                  child: Icon(
                                    isFav
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_outline_rounded,
                                    color: isFav
                                        ? Colors.redAccent
                                        : c.textTertiary,
                                    size: 18,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        tool.localDesc(isAr),
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: c.textSecondary,
                          height: 1.6,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          children: tags
                              .take(4)
                              .map((t) => _TagChip(label: t, colors: c))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Tool Detail Screen ───────────────────────────────────────────────────────
class ToolDetailScreen extends StatelessWidget {
  final AiTool tool;
  const ToolDetailScreen({super.key, required this.tool});

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LangService>().isArabic;
    final c    = AppColors.of(context);
    final color = categoryColor(tool.category);
    final tags  = tool.displayTags(isAr);

    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: c.surface,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Consumer<FavService>(
                builder: (_, favs, _) {
                  final isFav = favs.isFav(tool.id);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_outline_rounded,
                          key: ValueKey(isFav),
                          color: isFav ? Colors.redAccent : c.textSecondary,
                        ),
                      ),
                      onPressed: () => favs.toggle(tool.id),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.2),
                      c.surface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: color.withValues(alpha: 0.45),
                                  width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.25),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                tool.icon,
                                style: const TextStyle(fontSize: 42),
                              ),
                            ),
                          ),
                          if (tool.isNew)
                            Transform.translate(
                              offset: const Offset(6, -6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [
                                    Color(0xFFF59E0B),
                                    Color(0xFFF97316),
                                  ]),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isAr ? 'جديد' : 'NEW',
                                  style: GoogleFonts.cairo(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tool.localName(isAr),
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: color.withValues(alpha: 0.4), width: 1),
                        ),
                        child: Text(
                          categoryLabel(tool.category, isAr),
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags row
                  if (tags.isNotEmpty) ...[
                    Wrap(
                      children: tags
                          .map((t) => _TagChip(label: t, colors: c))
                          .toList(),
                    ),
                    const SizedBox(height: 14),
                  ],
                  // Rating row
                  _InfoCard(
                    icon: Icons.star_rounded,
                    title: isAr ? 'التقييم' : 'Rating',
                    color: const Color(0xFFF59E0B),
                    colors: c,
                    child: Row(
                      children: [
                        ...List.generate(5, (i) {
                          final filled = i < tool.rating.floor();
                          final half = !filled &&
                              i < tool.rating &&
                              (tool.rating - i) >= 0.5;
                          return Icon(
                            filled
                                ? Icons.star_rounded
                                : half
                                    ? Icons.star_half_rounded
                                    : Icons.star_outline_rounded,
                            size: 20,
                            color: const Color(0xFFF59E0B),
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          tool.rating.toStringAsFixed(1),
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // About card
                  _InfoCard(
                    icon: Icons.info_outline_rounded,
                    title: isAr ? 'عن الأداة' : 'About',
                    color: color,
                    colors: c,
                    child: Text(
                      tool.localDesc(isAr),
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: c.textSecondary,
                        height: 1.75,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // URL card
                  _InfoCard(
                    icon: Icons.link_rounded,
                    title: isAr ? 'الموقع الرسمي' : 'Website',
                    color: color,
                    colors: c,
                    child: Text(
                      tool.url,
                      style: GoogleFonts.cairo(
                          fontSize: 13, color: c.textTertiary),
                    ),
                  ),
                  const SizedBox(height: 26),
                  // Open button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withValues(alpha: 0.75)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => _launch(context, tool.url, isAr),
                        icon: const Icon(Icons.open_in_new_rounded, size: 20),
                        label: Text(
                          isAr ? 'فتح الموقع في المتصفح' : 'Open in Browser',
                          style: GoogleFonts.cairo(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: c.textSecondary,
                        side: BorderSide(color: c.border, width: 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        isAr ? 'رجوع' : 'Go Back',
                        style: GoogleFonts.cairo(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launch(BuildContext context, String url, bool isAr) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') {
      _showLaunchError(context, isAr);
      return;
    }
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) _showLaunchError(context, isAr);
    } on Exception {
      if (context.mounted) _showLaunchError(context, isAr);
    }
  }

  void _showLaunchError(BuildContext context, bool isAr) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAr ? 'تعذّر فتح الرابط' : 'Could not open the link',
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─── Info Card ────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final AppColors colors;
  final Widget child;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.colors,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ─── Favorites Screen ─────────────────────────────────────────────────────────
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<FavService, LangService>(
      builder: (_, favs, lang, _) {
        final isAr     = lang.isArabic;
        final favorites = favs.favorites;
        final c        = AppColors.of(context);

        if (favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: Colors.red.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Icon(Icons.favorite_outline_rounded,
                      size: 40, color: Colors.red.shade400),
                ),
                const SizedBox(height: 20),
                Text(
                  isAr ? 'لا توجد مفضلات بعد' : 'No favorites yet',
                  style: GoogleFonts.cairo(
                    color: c.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isAr
                      ? 'اضغط على ♡ لإضافة أدوات للمفضلة'
                      : 'Tap ♡ on any tool to save it here',
                  style:
                      GoogleFonts.cairo(color: c.textTertiary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: favorites.length,
          itemBuilder: (_, i) => ToolCard(tool: favorites[i]),
        );
      },
    );
  }
}
