import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/tools_data.dart';
import '../models/ai_tool.dart';
import '../screens/compare_screen.dart';
import '../screens/tool_detail_screen.dart';
import '../services/app_service.dart';
import '../services/compare_service.dart';
import '../theme/app_colors.dart';
import '../widgets/tag_chip.dart';

// ─── Info Card ────────────────────────────────────────────────────────────────
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final AppColors colors;
  final Widget child;

  const InfoCard({
    super.key,
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

// ─── Animated Card (staggered entry) ─────────────────────────────────────────
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final int index;
  const AnimatedCard({super.key, required this.child, required this.index});

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    final delay = (widget.index * 40).clamp(0, 400);
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}

// ─── Tool Card ────────────────────────────────────────────────────────────────
class ToolCard extends StatelessWidget {
  final AiTool tool;
  final bool heroEnabled;
  const ToolCard({super.key, required this.tool, this.heroEnabled = true});

  @override
  Widget build(BuildContext context) {
    final isAr  = context.watch<LangService>().isArabic;
    final c     = AppColors.of(context);
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
            PageRouteBuilder(
              pageBuilder: (ctx2, a1, a2) => ToolDetailScreen(tool: tool),
              transitionDuration: const Duration(milliseconds: 350),
              transitionsBuilder: (ctx2, anim, a2, child) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                    parent: anim, curve: Curves.easeOutCubic)),
                child: child,
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.border, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          // Icon with optional Hero
                          _buildIcon(color),
                          const SizedBox(width: 12),
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
                          // Compare button
                          Consumer2<CompareService, LangService>(
                            builder: (ctx, compare, lang, _) {
                              final isSelected = compare.selectedTool?.id == tool.id;
                              return GestureDetector(
                                onTap: () {
                                  if (compare.selectedTool == null) {
                                    compare.selectTool(tool);
                                  } else if (compare.selectedTool!.id == tool.id) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                                      content: Text(
                                        lang.isArabic
                                            ? 'اختر أداة مختلفة'
                                            : 'Choose a different tool',
                                        style: GoogleFonts.cairo(),
                                      ),
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                    ));
                                  } else {
                                    final t1 = compare.selectedTool!;
                                    Navigator.push(
                                      ctx,
                                      PageRouteBuilder(
                                        pageBuilder: (c2, a1, a2) =>
                                            CompareScreen(tool1: t1, tool2: tool),
                                        transitionDuration:
                                            const Duration(milliseconds: 350),
                                        transitionsBuilder: (c2, anim, a2, child) =>
                                            SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(1, 0),
                                            end: Offset.zero,
                                          ).animate(CurvedAnimation(
                                              parent: anim,
                                              curve: Curves.easeOutCubic)),
                                          child: child,
                                        ),
                                      ),
                                    );
                                    compare.clearSelection();
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? kPrimary.withValues(alpha: 0.15)
                                        : c.bg,
                                    borderRadius: BorderRadius.circular(11),
                                    border: Border.all(
                                      color: isSelected
                                          ? kPrimary.withValues(alpha: 0.3)
                                          : c.border,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.compare_arrows_rounded,
                                    color: isSelected ? kPrimary : c.textTertiary,
                                    size: 18,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 6),
                          // Favorite with scale animation
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
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    transitionBuilder: (child, anim) =>
                                        ScaleTransition(
                                            scale: anim, child: child),
                                    child: Icon(
                                      isFav
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_outline_rounded,
                                      key: ValueKey(isFav),
                                      color: isFav
                                          ? Colors.redAccent
                                          : c.textTertiary,
                                      size: 18,
                                    ),
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
                              .map((t) => TagChip(label: t, colors: c))
                              .toList(),
                        ),
                      ],
                      // View count
                      Consumer<ViewCountService>(
                        builder: (_, vc, _) {
                          final count = vc.getCount(tool.id);
                          if (count == 0) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Icon(Icons.visibility_rounded,
                                    size: 12, color: c.textTertiary),
                                const SizedBox(width: 4),
                                Text(
                                  '$count',
                                  style: GoogleFonts.cairo(
                                      fontSize: 11, color: c.textTertiary),
                                ),
                              ],
                            ),
                          );
                        },
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

  Widget _buildIcon(Color color) {
    final iconWidget = Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Center(child: Text(tool.icon, style: const TextStyle(fontSize: 24))),
    );
    if (!heroEnabled) return iconWidget;
    return Hero(tag: 'tool_icon_${tool.id}', child: iconWidget);
  }
}
