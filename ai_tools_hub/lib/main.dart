import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data/tools_data.dart';
import 'models/ai_tool.dart';
import 'services/app_service.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────
const kBg        = Color(0xFF0A0E27);
const kCard      = Color(0xFF1A1F3A);
const kSurface   = Color(0xFF131729);
const kPrimary   = Color(0xFF6366F1);
const kSecondary = Color(0xFF8B5CF6);
const kBorder    = Color(0xFF2A2F52);

// ─── Entry ────────────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LangService(prefs)),
      ChangeNotifierProvider(create: (_) => FavService(prefs)),
    ],
    child: const MyApp(),
  ));
}

// ─── App ──────────────────────────────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LangService>(
      builder: (_, lang, child) => MaterialApp(
        title: 'AI Tools Hub',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        builder: (ctx, widget) => Directionality(
          textDirection:
              lang.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: widget!,
        ),
        home: const HomeScreen(),
      ),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: kBg,
      colorScheme: const ColorScheme.dark(
        primary: kPrimary,
        secondary: kSecondary,
        surface: kCard,
        onPrimary: Colors.white,
        onSurface: Colors.white,
      ),
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: kSurface,
        indicatorColor: kPrimary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? kPrimary : Colors.white38,
          );
        }),
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
    final lang = context.watch<LangService>();
    final isAr = lang.isArabic;

    return Scaffold(
      backgroundColor: kBg,
      appBar: _HubAppBar(isArabic: isAr, onToggleLang: lang.toggle),
      body: IndexedStack(
        index: _tab,
        children: const [ToolsListScreen(), FavoritesScreen()],
      ),
      bottomNavigationBar: _buildNav(isAr),
    );
  }

  Widget _buildNav(bool isAr) {
    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(top: BorderSide(color: kBorder, width: 1)),
      ),
      child: NavigationBar(
        selectedIndex: _tab,
        backgroundColor: Colors.transparent,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined, color: Colors.white38),
            selectedIcon:
                const Icon(Icons.dashboard_rounded, color: kPrimary),
            label: isAr ? 'الأدوات' : 'Tools',
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_outline_rounded,
                color: Colors.white38),
            selectedIcon:
                const Icon(Icons.favorite_rounded, color: kPrimary),
            label: isAr ? 'المفضلة' : 'Favorites',
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

  const _HubAppBar({required this.isArabic, required this.onToggleLang});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kSurface, kCard],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(bottom: BorderSide(color: kBorder, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Logo
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
              // Title
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
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      isArabic
                          ? 'أدوات الذكاء الاصطناعي'
                          : 'AI Tools Directory',
                      style: GoogleFonts.cairo(
                          fontSize: 11, color: Colors.white38),
                    ),
                  ],
                ),
              ),
              // Language toggle
              GestureDetector(
                onTap: onToggleLang,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: kPrimary.withValues(alpha: 0.4), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language_rounded,
                          size: 14, color: kPrimary),
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

// ─── Tools List Screen ────────────────────────────────────────────────────────
class ToolsListScreen extends StatefulWidget {
  const ToolsListScreen({super.key});

  @override
  State<ToolsListScreen> createState() => _ToolsListScreenState();
}

class _ToolsListScreenState extends State<ToolsListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  ToolCategory? _category;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AiTool> _filtered(bool isAr) => kAllTools.where((t) {
        final q = _query.toLowerCase();
        final nameMatch = t.localName(isAr).toLowerCase().contains(q);
        final descMatch = t.localDesc(isAr).toLowerCase().contains(q);
        final catMatch = _category == null || t.category == _category;
        return (q.isEmpty || nameMatch || descMatch) && catMatch;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LangService>().isArabic;
    final filtered = _filtered(isAr);

    return Column(
      children: [
        _buildSearchSection(isAr),
        Expanded(
          child: filtered.isEmpty
              ? _EmptyState(isArabic: isAr)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => ToolCard(tool: filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(bool isAr) {
    return Container(
      color: kSurface,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: isAr ? 'ابحث عن أداة...' : 'Search tools...',
              hintStyle: GoogleFonts.cairo(
                  color: Colors.white38, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: kPrimary, size: 22),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.cancel_rounded,
                          color: Colors.white38, size: 20),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: kCard,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kBorder, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kPrimary, width: 1.5),
              ),
            ),
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
                  onTap: () => setState(() => _category = null),
                ),
                ...kCategories.map(
                  (cat) => _CategoryChip(
                    label: categoryLabel(cat, isAr),
                    icon: categoryIcon(cat),
                    color: categoryColor(cat),
                    selected: _category == cat,
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
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: [color, color.withValues(alpha: 0.65)],
                  )
                : null,
            color: selected ? null : kCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? Colors.transparent : kBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 14,
                  color: selected ? Colors.white : color),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isArabic;
  const _EmptyState({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: kBorder),
            ),
            child: const Icon(Icons.search_off_rounded,
                size: 40, color: kPrimary),
          ),
          const SizedBox(height: 20),
          Text(
            isArabic ? 'لا توجد نتائج' : 'No results found',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'جرب البحث بكلمات أخرى'
                : 'Try different keywords',
            style:
                GoogleFonts.cairo(color: Colors.white38, fontSize: 14),
          ),
        ],
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
    final color = categoryColor(tool.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withValues(alpha: 0.08),
          highlightColor: color.withValues(alpha: 0.04),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ToolDetailScreen(tool: tool)),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorder, width: 1),
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category icon
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: color.withValues(alpha: 0.25),
                                  width: 1),
                            ),
                            child: Center(
                              child: Text(
                                tool.icon,
                                style: const TextStyle(fontSize: 26),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Name + badge
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tool.localName(isAr),
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius:
                                        BorderRadius.circular(6),
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
                          // Favorite button
                          Consumer<FavService>(
                            builder: (_, favs, _) {
                              final isFav = favs.isFav(tool.id);
                              return GestureDetector(
                                onTap: () => favs.toggle(tool.id),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isFav
                                        ? Colors.red
                                            .withValues(alpha: 0.15)
                                        : kBg,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    border: Border.all(
                                        color: isFav
                                            ? Colors.red
                                                .withValues(alpha: 0.3)
                                            : kBorder,
                                        width: 1),
                                  ),
                                  child: Icon(
                                    isFav
                                        ? Icons.favorite_rounded
                                        : Icons
                                            .favorite_outline_rounded,
                                    color: isFav
                                        ? Colors.redAccent
                                        : Colors.white38,
                                    size: 20,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tool.localDesc(isAr),
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.white54,
                          height: 1.6,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
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
    final color = categoryColor(tool.category);

    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            backgroundColor: kSurface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white),
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
                          color:
                              isFav ? Colors.redAccent : Colors.white70,
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
                      color.withValues(alpha: 0.25),
                      kSurface,
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
                        child: Text(
                          tool.icon,
                          style: const TextStyle(fontSize: 42),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        tool.localName(isAr),
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
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
                  // About card
                  _InfoCard(
                    icon: Icons.info_outline_rounded,
                    title: isAr ? 'عن الأداة' : 'About',
                    color: color,
                    child: Text(
                      tool.localDesc(isAr),
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.75,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // URL card
                  _InfoCard(
                    icon: Icons.link_rounded,
                    title: isAr ? 'الموقع الرسمي' : 'Website',
                    color: color,
                    child: Text(
                      tool.url,
                      style: GoogleFonts.cairo(
                          fontSize: 13, color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Open in browser button
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
                        onPressed: () =>
                            _launch(context, tool.url, isAr),
                        icon: const Icon(Icons.open_in_new_rounded,
                            size: 20),
                        label: Text(
                          isAr ? 'فتح الموقع في المتصفح' : 'Open in Browser',
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Back button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: kBorder, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        isAr ? 'رجوع' : 'Go Back',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
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

  Future<void> _launch(
      BuildContext context, String url, bool isAr) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') {
      _showLaunchError(context, isAr);
      return;
    }
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder, width: 1),
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
        final isAr = lang.isArabic;
        final favorites = favs.favorites;

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
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isAr
                      ? 'اضغط على ♡ لإضافة أدوات للمفضلة'
                      : 'Tap ♡ on any tool to save it here',
                  style: GoogleFonts.cairo(
                      color: Colors.white38, fontSize: 14),
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
