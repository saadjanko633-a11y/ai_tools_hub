import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/tools_data.dart';
import '../models/ai_tool.dart';
import '../services/app_service.dart';
import '../theme/app_colors.dart';
import '../widgets/category_chip.dart';
import '../widgets/tool_card.dart';
import 'tool_detail_screen.dart';

// ─── Sort Order ───────────────────────────────────────────────────────────────
enum SortOrder { defaultOrder, nameAsc, ratingDesc, newFirst, mostVisited }

// ─── Tools List Screen ────────────────────────────────────────────────────────
class ToolsListScreen extends StatefulWidget {
  const ToolsListScreen({super.key});

  @override
  State<ToolsListScreen> createState() => _ToolsListScreenState();
}

class _ToolsListScreenState extends State<ToolsListScreen> {
  final _searchCtrl = TextEditingController();
  String _query        = '';
  ToolCategory? _category;
  SortOrder _sortOrder = SortOrder.defaultOrder;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AiTool> _filtered(bool isAr, ViewCountService viewCounts) {
    var list = kAllTools.where((t) {
      final q        = _query.toLowerCase();
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
      case SortOrder.mostVisited:
        list.sort((a, b) =>
            viewCounts.getCount(b.id).compareTo(viewCounts.getCount(a.id)));
      case SortOrder.defaultOrder:
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isAr       = context.watch<LangService>().isArabic;
    final viewCounts = context.watch<ViewCountService>();
    final c          = AppColors.of(context);
    final filtered   = _filtered(isAr, viewCounts);
    final showFeatured = _query.isEmpty && _category == null;

    return Column(
      children: [
        if (showFeatured) _buildFeaturedSection(isAr, c),
        _buildSearchSection(isAr, c),
        Expanded(
          child: filtered.isEmpty
              ? _EmptyState(isArabic: isAr, colors: c)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => AnimatedCard(
                    index: i,
                    child: ToolCard(tool: filtered[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFeaturedSection(bool isAr, AppColors c) {
    final featured = kAllTools.where((t) => t.isFeatured).toList();
    if (featured.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              isAr ? '✨ الأدوات المميزة' : '✨ Featured Tools',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
              ),
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: featured.length,
              itemBuilder: (_, i) =>
                  _FeaturedCard(tool: featured[i], isAr: isAr, colors: c),
            ),
          ),
        ],
      ),
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
                CategoryChip(
                  label: isAr ? 'الكل' : 'All',
                  icon: Icons.apps_rounded,
                  color: kPrimary,
                  selected: _category == null,
                  colors: c,
                  onTap: () => setState(() => _category = null),
                ),
                ...kCategories.map(
                  (cat) => CategoryChip(
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
        hintStyle:
            GoogleFonts.cairo(color: c.textTertiary, fontSize: 14),
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
        _sortItem(SortOrder.mostVisited, Icons.visibility_rounded,
            isAr ? 'الأكثر زيارة' : 'Most Visited', c),
      ],
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 52,
        decoration: BoxDecoration(
          color: isActive ? kPrimary.withValues(alpha: 0.15) : c.card,
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

// ─── Featured Card ────────────────────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final AiTool tool;
  final bool isAr;
  final AppColors colors;

  const _FeaturedCard({
    required this.tool,
    required this.isAr,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(tool.category);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (ctx2, a1, a2) => ToolDetailScreen(tool: tool),
          transitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (ctx2, anim, a2, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),
      child: Container(
        width: 138,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.65)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tool.icon, style: const TextStyle(fontSize: 26)),
              const Spacer(),
              Text(
                tool.localName(isAr),
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 10, color: Colors.white),
                    const SizedBox(width: 3),
                    Text(
                      tool.rating.toStringAsFixed(1),
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
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
            child: const Icon(Icons.search_off_rounded,
                size: 40, color: kPrimary),
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
