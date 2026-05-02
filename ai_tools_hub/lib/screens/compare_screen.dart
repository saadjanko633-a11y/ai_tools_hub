import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/tools_data.dart';
import '../models/ai_tool.dart';
import '../services/app_service.dart';
import '../theme/app_colors.dart';
import '../widgets/tool_card.dart';

class CompareScreen extends StatelessWidget {
  final AiTool tool1;
  final AiTool tool2;

  const CompareScreen({super.key, required this.tool1, required this.tool2});

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LangService>().isArabic;
    final c    = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isAr ? 'مقارنة الأدوات' : 'Compare Tools',
          style: GoogleFonts.cairo(
            fontSize: 17, fontWeight: FontWeight.w700, color: c.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Tool headers ───────────────────────────────────────────────
            Container(
              color: c.surface,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _ToolHeader(tool: tool1, isAr: isAr, colors: c)),
                  Container(width: 1, height: 100, color: c.border),
                  Expanded(child: _ToolHeader(tool: tool2, isAr: isAr, colors: c)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // ── Comparison rows ────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.border),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _CompareRow(
                    isAr: isAr, colors: c,
                    labelEn: 'Rating', labelAr: 'التقييم',
                    left: _ratingCell(tool1.rating, c),
                    right: _ratingCell(tool2.rating, c),
                    isDifferent: tool1.rating != tool2.rating,
                    isFirst: true,
                  ),
                  Divider(height: 1, color: c.border),
                  _CompareRow(
                    isAr: isAr, colors: c,
                    labelEn: 'Category', labelAr: 'الفئة',
                    left: _categoryCell(tool1.category, isAr),
                    right: _categoryCell(tool2.category, isAr),
                    isDifferent: tool1.category != tool2.category,
                  ),
                  Divider(height: 1, color: c.border),
                  _CompareRow(
                    isAr: isAr, colors: c,
                    labelEn: 'Pricing', labelAr: 'التسعير',
                    left: _pricingCell(tool1.isFree, isAr, c),
                    right: _pricingCell(tool2.isFree, isAr, c),
                    isDifferent: tool1.isFree != tool2.isFree,
                  ),
                  Divider(height: 1, color: c.border),
                  _CompareRow(
                    isAr: isAr, colors: c,
                    labelEn: 'Free Plan', labelAr: 'نسخة مجانية',
                    left: _boolCell(tool1.hasFreePlan),
                    right: _boolCell(tool2.hasFreePlan),
                    isDifferent: tool1.hasFreePlan != tool2.hasFreePlan,
                  ),
                  Divider(height: 1, color: c.border),
                  _CompareRow(
                    isAr: isAr, colors: c,
                    labelEn: 'Tags', labelAr: 'الوسوم',
                    left: _TagsCell(tags: tool1.displayTags(isAr), colors: c),
                    right: _TagsCell(tags: tool2.displayTags(isAr), colors: c),
                    isDifferent: false,
                  ),
                  Divider(height: 1, color: c.border),
                  _CompareRow(
                    isAr: isAr, colors: c,
                    labelEn: 'Website', labelAr: 'الموقع',
                    left: _WebsiteCell(url: tool1.url, isAr: isAr),
                    right: _WebsiteCell(url: tool2.url, isAr: isAr),
                    isDifferent: false,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Tool Header ──────────────────────────────────────────────────────────────
class _ToolHeader extends StatelessWidget {
  final AiTool tool;
  final bool isAr;
  final AppColors colors;
  const _ToolHeader({required this.tool, required this.isAr, required this.colors});

  @override
  Widget build(BuildContext context) {
    final c     = colors;
    final color = categoryColor(tool.category);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            ),
            child: Center(child: Text(tool.icon, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 8),
          Text(
            tool.localName(isAr),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 13, fontWeight: FontWeight.w700, color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              categoryLabel(tool.category, isAr),
              style: GoogleFonts.cairo(
                fontSize: 10, fontWeight: FontWeight.w700, color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Compare Row ──────────────────────────────────────────────────────────────
class _CompareRow extends StatelessWidget {
  final bool isAr;
  final AppColors colors;
  final String labelEn;
  final String labelAr;
  final Widget left;
  final Widget right;
  final bool isDifferent;
  final bool isFirst;
  final bool isLast;

  const _CompareRow({
    required this.isAr,
    required this.colors,
    required this.labelEn,
    required this.labelAr,
    required this.left,
    required this.right,
    required this.isDifferent,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final radius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(12) : Radius.zero,
      bottom: isLast ? const Radius.circular(12) : Radius.zero,
    );
    return Container(
      decoration: BoxDecoration(
        color: isDifferent ? kPrimary.withValues(alpha: 0.06) : Colors.transparent,
        borderRadius: radius,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              isAr ? labelAr : labelEn,
              style: GoogleFonts.cairo(
                fontSize: 11, fontWeight: FontWeight.w600, color: c.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: left,
                ),
              ),
              Container(width: 1, height: 32, color: c.border),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Cell helpers ─────────────────────────────────────────────────────────────

Widget _ratingCell(double rating, AppColors c) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
    const SizedBox(width: 4),
    Text(
      rating.toStringAsFixed(1),
      style: GoogleFonts.cairo(
        fontSize: 14, fontWeight: FontWeight.w700, color: c.textPrimary,
      ),
    ),
  ],
);

Widget _categoryCell(ToolCategory cat, bool isAr) {
  final color = categoryColor(cat);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      categoryLabel(cat, isAr),
      style: GoogleFonts.cairo(
        fontSize: 12, fontWeight: FontWeight.w700, color: color,
      ),
    ),
  );
}

Widget _pricingCell(bool isFree, bool isAr, AppColors c) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text(isFree ? '💚' : '💰', style: const TextStyle(fontSize: 14)),
    const SizedBox(width: 6),
    Text(
      isFree ? (isAr ? 'مجاني' : 'Free') : (isAr ? 'مدفوع' : 'Paid'),
      style: GoogleFonts.cairo(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: isFree ? const Color(0xFF10B981) : c.textSecondary,
      ),
    ),
  ],
);

Widget _boolCell(bool value) => Icon(
  value ? Icons.check_circle_rounded : Icons.cancel_rounded,
  color: value ? const Color(0xFF10B981) : const Color(0xFFEF4444),
  size: 22,
);

class _TagsCell extends StatelessWidget {
  final List<String> tags;
  final AppColors colors;
  const _TagsCell({required this.tags, required this.colors});

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return Text('—', style: GoogleFonts.cairo(color: colors.textTertiary, fontSize: 13));
    }
    return Wrap(
      children: tags.take(4).map((t) => TagChip(label: t, colors: colors)).toList(),
    );
  }
}

class _WebsiteCell extends StatelessWidget {
  final String url;
  final bool isAr;
  const _WebsiteCell({required this.url, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final uri = Uri.tryParse(url);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      icon: const Icon(Icons.open_in_new_rounded, size: 14),
      label: Text(isAr ? 'فتح' : 'Open'),
      style: OutlinedButton.styleFrom(
        foregroundColor: kPrimary,
        side: const BorderSide(color: kPrimary),
        textStyle: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
