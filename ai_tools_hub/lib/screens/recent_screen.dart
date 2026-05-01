import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/tools_data.dart';
import '../models/ai_tool.dart';
import '../services/app_service.dart';
import '../theme/app_colors.dart';

class RecentScreen extends StatelessWidget {
  final void Function(AiTool tool) onTap;
  const RecentScreen({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer2<RecentService, LangService>(
      builder: (ctx, recent, lang, _) {
        final isAr  = lang.isArabic;
        final c     = AppColors.of(ctx);
        final tools = recent.recentTools;

        if (tools.isEmpty) {
          return _EmptyRecent(isAr: isAr, colors: c);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isAr, c, recent),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: tools.length,
                itemBuilder: (_, i) => _RecentTile(
                  tool: tools[i],
                  isAr: isAr,
                  colors: c,
                  onTap: () => onTap(tools[i]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext ctx, bool isAr, AppColors c, RecentService recent) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
      color: c.surface,
      child: Row(
        children: [
          Icon(Icons.history_rounded, size: 18, color: kPrimary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isAr ? 'آخر الأدوات المستخدمة' : 'Recently Viewed',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: recent.clear,
            icon: Icon(Icons.delete_outline_rounded, size: 15, color: Colors.red.shade400),
            label: Text(
              isAr ? 'مسح' : 'Clear',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.red.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyRecent extends StatelessWidget {
  final bool isAr;
  final AppColors colors;
  const _EmptyRecent({required this.isAr, required this.colors});

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
              color: kPrimary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: kPrimary.withValues(alpha: 0.2), width: 1),
            ),
            child: const Icon(Icons.history_rounded, size: 40, color: kPrimary),
          ),
          const SizedBox(height: 20),
          Text(
            isAr ? 'لا يوجد سجل بعد' : 'No history yet',
            style: GoogleFonts.cairo(
              color: c.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              isAr
                  ? 'افتح أي أداة وستظهر هنا تلقائياً'
                  : 'Open any tool and it will appear here',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(color: c.textTertiary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recent tile ──────────────────────────────────────────────────────────────
class _RecentTile extends StatelessWidget {
  final AiTool tool;
  final bool isAr;
  final AppColors colors;
  final VoidCallback onTap;

  const _RecentTile({
    required this.tool,
    required this.isAr,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c     = colors;
    final color = categoryColor(tool.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border, width: 1),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
                  ),
                  child: Center(
                    child: Text(tool.icon, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + category
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
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: c.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (tool.isNew) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                isAr ? 'جديد' : 'NEW',
                                style: GoogleFonts.cairo(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              categoryLabel(tool.category, isAr),
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.star_rounded, size: 12, color: const Color(0xFFF59E0B)),
                          const SizedBox(width: 2),
                          Text(
                            tool.rating.toStringAsFixed(1),
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: c.textTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: c.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
