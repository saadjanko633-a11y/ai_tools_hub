import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/app_service.dart';
import '../theme/app_colors.dart';
import '../widgets/tool_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<FavService, LangService>(
      builder: (_, favs, lang, _) {
        final isAr      = lang.isArabic;
        final favorites = favs.favorites;
        final c         = AppColors.of(context);

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
                  style: GoogleFonts.cairo(
                      color: c.textTertiary, fontSize: 14),
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
