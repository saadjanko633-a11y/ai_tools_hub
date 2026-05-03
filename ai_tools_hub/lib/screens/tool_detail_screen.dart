import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/tools_data.dart';
import '../models/ai_tool.dart';
import '../services/app_service.dart';
import '../services/compare_service.dart';
import '../theme/app_colors.dart';
import '../widgets/tag_chip.dart';
import '../widgets/tool_card.dart';
import 'compare_screen.dart';

class ToolDetailScreen extends StatefulWidget {
  final AiTool tool;
  const ToolDetailScreen({super.key, required this.tool});

  @override
  State<ToolDetailScreen> createState() => _ToolDetailScreenState();
}

class _ToolDetailScreenState extends State<ToolDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ViewCountService>().increment(widget.tool.id);
      context.read<RecentService>().add(widget.tool.id);
    });
  }

  Future<void> _share(bool isAr) async {
    final tool = widget.tool;
    final deepLink = 'aitoolshub://tool/${tool.id}';
    final text = isAr
        ? '🤖 ${tool.nameAr}\n\n📝 ${tool.descriptionAr}\n\nافتح مباشرة: $deepLink\n🌐 الرابط: ${tool.url}\n\n📱 شاركني الفكرة من تطبيق AI Tools Hub'
        : '🤖 ${tool.nameEn}\n\n📝 ${tool.descriptionEn}\n\nOpen directly: $deepLink\n🌐 Link: ${tool.url}\n\n📱 Shared from AI Tools Hub app';
    try {
      await Share.share(text);
    } catch (_) {}
  }

  Future<void> _copyLink(bool isAr) async {
    try {
      await Clipboard.setData(ClipboardData(text: widget.tool.url));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr ? '✅ تم نسخ الرابط' : '✅ Link copied',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {}
  }

  Future<void> _launch(String url, bool isAr) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') {
      _showLaunchError(isAr);
      return;
    }
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) _showLaunchError(isAr);
    } on Exception {
      if (mounted) _showLaunchError(isAr);
    }
  }

  void _showLaunchError(bool isAr) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAr ? 'تعذّر فتح الرابط' : 'Could not open the link',
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr  = context.watch<LangService>().isArabic;
    final c     = AppColors.of(context);
    final tool  = widget.tool;
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
              // Compare button
              Consumer2<CompareService, LangService>(
                builder: (ctx, compare, lang, _) {
                  final isSelected = compare.selectedTool?.id == tool.id;
                  return IconButton(
                    icon: Icon(
                      Icons.compare_arrows_rounded,
                      color: isSelected ? kPrimary : c.textSecondary,
                    ),
                    onPressed: () {
                      if (compare.selectedTool == null) {
                        compare.selectTool(tool);
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                          content: Text(
                            lang.isArabic
                                ? 'تم اختيار الأداة للمقارنة'
                                : 'Tool selected for comparison',
                            style: GoogleFonts.cairo(),
                          ),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ));
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
                            transitionDuration: const Duration(milliseconds: 350),
                            transitionsBuilder: (c2, anim, a2, child) =>
                                SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                  parent: anim, curve: Curves.easeOutCubic)),
                              child: child,
                            ),
                          ),
                        );
                        compare.clearSelection();
                      }
                    },
                  );
                },
              ),
              // Share button
              IconButton(
                icon: Icon(Icons.share_rounded, color: c.textSecondary),
                onPressed: () => _share(isAr),
              ),
              // Favorite button
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
                              isFav ? Colors.redAccent : c.textSecondary,
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
                    colors: [color.withValues(alpha: 0.2), c.surface],
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
                          // Hero animation on the icon
                          Hero(
                            tag: 'tool_icon_${tool.id}',
                            child: Container(
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
                  if (tags.isNotEmpty) ...[
                    Wrap(
                      children: tags
                          .map((t) => TagChip(label: t, colors: c))
                          .toList(),
                    ),
                    const SizedBox(height: 14),
                  ],
                  InfoCard(
                    icon: Icons.star_rounded,
                    title: isAr ? 'التقييم' : 'Rating',
                    color: const Color(0xFFF59E0B),
                    colors: c,
                    child: Row(
                      children: [
                        ...List.generate(5, (i) {
                          final filled = i < tool.rating.floor();
                          final half   = !filled &&
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
                  InfoCard(
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
                  InfoCard(
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
                  // Open in Browser
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
                        onPressed: () => _launch(tool.url, isAr),
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
                  const SizedBox(height: 12),
                  // Copy Link
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _copyLink(isAr),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: Text(
                        isAr ? 'نسخ الرابط' : 'Copy Link',
                        style: GoogleFonts.cairo(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimary,
                        side: const BorderSide(color: kPrimary, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Go Back
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
}
