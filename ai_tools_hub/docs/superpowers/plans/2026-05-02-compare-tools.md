# Compare Tools Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a side-by-side tool comparison feature — compare button on ToolCard and ToolDetailScreen, backed by in-memory CompareService, rendering on a new CompareScreen.

**Architecture:** A new `CompareService` (ChangeNotifier) holds a single nullable `selectedTool`. Tapping compare on a first tool stores it; tapping on a second navigates to `CompareScreen` with both tools. `CompareScreen` renders a scrollable two-column table with difference highlighting.

**Tech Stack:** Flutter/Dart, Provider, GoogleFonts.cairo, url_launcher, existing AppColors/kPrimary constants.

---

## File Map

| Action | File |
|---|---|
| Create | `lib/services/compare_service.dart` |
| Modify | `lib/main.dart` — add CompareService to MultiProvider |
| Create | `lib/screens/compare_screen.dart` |
| Modify | `lib/widgets/tool_card.dart` — add compare button before fav button |
| Modify | `lib/screens/tool_detail_screen.dart` — add compare IconButton to AppBar actions |
| Modify | `test/widget_test.dart` — add CompareService unit tests |

---

## Task 1: CompareService

**Files:**
- Create: `lib/services/compare_service.dart`
- Modify: `test/widget_test.dart`

- [ ] **Step 1: Write failing unit tests for CompareService**

Replace `test/widget_test.dart` with:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_tools_hub/services/compare_service.dart';
import 'package:ai_tools_hub/models/ai_tool.dart';

void main() {
  group('placeholder', () {
    test('arithmetic', () => expect(1 + 1, 2));
  });

  group('CompareService', () {
    late CompareService service;

    const toolA = AiTool(
      id: 'a', nameEn: 'A', nameAr: 'أ',
      descriptionEn: 'desc', descriptionAr: 'وصف',
      category: ToolCategory.chat, icon: '🤖',
      url: 'https://a.com', isFree: true, hasFreePlan: true, rating: 4.5,
    );
    const toolB = AiTool(
      id: 'b', nameEn: 'B', nameAr: 'ب',
      descriptionEn: 'desc', descriptionAr: 'وصف',
      category: ToolCategory.coding, icon: '💻',
      url: 'https://b.com', isFree: false, hasFreePlan: true, rating: 4.2,
    );

    setUp(() => service = CompareService());

    test('initial selectedTool is null', () {
      expect(service.selectedTool, isNull);
    });

    test('selectTool sets selectedTool', () {
      service.selectTool(toolA);
      expect(service.selectedTool, toolA);
    });

    test('selectTool notifies listeners', () {
      var notified = false;
      service.addListener(() => notified = true);
      service.selectTool(toolA);
      expect(notified, isTrue);
    });

    test('selectTool replaces previous selection', () {
      service.selectTool(toolA);
      service.selectTool(toolB);
      expect(service.selectedTool, toolB);
    });

    test('clearSelection sets selectedTool to null', () {
      service.selectTool(toolA);
      service.clearSelection();
      expect(service.selectedTool, isNull);
    });

    test('clearSelection notifies listeners', () {
      service.selectTool(toolA);
      var notified = false;
      service.addListener(() => notified = true);
      service.clearSelection();
      expect(notified, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run tests — expect failure**

```
flutter test test/widget_test.dart
```

Expected: FAIL — `Target of URI doesn't exist: 'package:ai_tools_hub/services/compare_service.dart'`

- [ ] **Step 3: Create CompareService**

Create `lib/services/compare_service.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/ai_tool.dart';

class CompareService extends ChangeNotifier {
  AiTool? selectedTool;

  void selectTool(AiTool tool) {
    selectedTool = tool;
    notifyListeners();
  }

  void clearSelection() {
    selectedTool = null;
    notifyListeners();
  }
}
```

- [ ] **Step 4: Run tests — expect all pass**

```
flutter test test/widget_test.dart
```

Expected: All 7 tests pass, 0 failures.

- [ ] **Step 5: Commit**

```
git -C path/to/ai_tools_hub add lib/services/compare_service.dart test/widget_test.dart
git -C path/to/ai_tools_hub commit -m "feat: add CompareService with unit tests"
```

> Replace `path/to/ai_tools_hub` with the actual worktree path, e.g. `C:\SRC\.worktrees\refactor-split-files\ai_tools_hub` on Windows or the equivalent absolute path on your system.

---

## Task 2: Register CompareService in MultiProvider

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Add import**

In `lib/main.dart`, add this import after the existing `services/app_service.dart` import (line 13):

```dart
import 'services/compare_service.dart';
```

- [ ] **Step 2: Add to MultiProvider**

In `lib/main.dart`, the `providers` list currently ends at line 97:

```dart
      ChangeNotifierProvider(create: (_) => RecentService(prefs)),
```

Add `CompareService` after it (no `prefs` argument — it is in-memory only):

```dart
      ChangeNotifierProvider(create: (_) => RecentService(prefs)),
      ChangeNotifierProvider(create: (_) => CompareService()),
```

- [ ] **Step 3: Run analyze and tests**

```
flutter analyze
flutter test test/widget_test.dart
```

Expected: 0 issues, all tests pass.

- [ ] **Step 4: Commit**

```
git add lib/main.dart
git commit -m "feat: register CompareService in MultiProvider"
```

---

## Task 3: CompareScreen

**Files:**
- Create: `lib/screens/compare_screen.dart`

- [ ] **Step 1: Create the file**

Create `lib/screens/compare_screen.dart` with the full content below:

```dart
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
```

- [ ] **Step 2: Run analyze**

```
flutter analyze
```

Expected: 0 issues.

- [ ] **Step 3: Run tests**

```
flutter test test/widget_test.dart
```

Expected: All tests pass.

- [ ] **Step 4: Commit**

```
git add lib/screens/compare_screen.dart
git commit -m "feat: add CompareScreen with side-by-side comparison table"
```

---

## Task 4: Add Compare Button to ToolCard

**Files:**
- Modify: `lib/widgets/tool_card.dart`

- [ ] **Step 1: Add imports**

In `lib/widgets/tool_card.dart`, the existing imports are:

```dart
import '../services/app_service.dart';
```

Add the compare service and screen imports after the existing imports:

```dart
import '../services/app_service.dart';
import '../services/compare_service.dart';
import '../screens/compare_screen.dart';
```

- [ ] **Step 2: Add compare button before the fav button**

In `lib/widgets/tool_card.dart`, find the comment `// Favorite with scale animation` (around line 310). Insert the compare button widget **before** that comment:

```dart
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
                                    compare.clearSelection();
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
```

- [ ] **Step 3: Run analyze and tests**

```
flutter analyze
flutter test test/widget_test.dart
```

Expected: 0 issues, all tests pass.

- [ ] **Step 4: Commit**

```
git add lib/widgets/tool_card.dart
git commit -m "feat: add compare button to ToolCard"
```

---

## Task 5: Add Compare Button to ToolDetailScreen

**Files:**
- Modify: `lib/screens/tool_detail_screen.dart`

- [ ] **Step 1: Add imports**

In `lib/screens/tool_detail_screen.dart`, add after the existing `app_service.dart` import line:

```dart
import '../services/compare_service.dart';
import 'compare_screen.dart';
```

(`compare_screen.dart` is in the same `lib/screens/` directory, so no `../screens/` prefix.)

- [ ] **Step 2: Add compare IconButton to AppBar actions**

In `lib/screens/tool_detail_screen.dart`, find the line `// Share button` inside the `SliverAppBar` `actions:` list (around line 117). Insert the compare button Consumer2 **before** it. Do **not** remove or modify the existing share button or fav Consumer. The insertion is:

```dart
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
                        compare.clearSelection();
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
                      }
                    },
                  );
                },
              ),
              // Share button  ← this line already exists; stop here, keep everything below unchanged
```

- [ ] **Step 3: Run analyze and tests**

```
flutter analyze
flutter test test/widget_test.dart
```

Expected: 0 issues, all tests pass.

- [ ] **Step 4: Commit**

```
git add lib/screens/tool_detail_screen.dart
git commit -m "feat: add compare button to ToolDetailScreen AppBar"
```

---

## Task 6: Verify on Emulator

**Files:** None

- [ ] **Step 1: Run full analyze**

```
flutter analyze
```

Expected output ends with: `No issues found!`

- [ ] **Step 2: Run full test suite**

```
flutter test
```

Expected: All tests pass, 0 failures.

- [ ] **Step 3: Run on emulator**

```
flutter run -d emulator-5554
```

Manual test checklist:
- [ ] Tap compare on Tool A → button turns indigo (highlighted)
- [ ] Tap compare on Tool A again → SnackBar: "Choose a different tool" / "اختر أداة مختلفة"
- [ ] Tap compare on Tool B → navigates to CompareScreen
- [ ] CompareScreen shows both tool headers with icons, names, category badges
- [ ] Rows that differ (Rating, Category, Pricing, Free Plan) have indigo highlight
- [ ] Tags row shows TagChip widgets
- [ ] Website buttons open browser
- [ ] Back from CompareScreen → compare button no longer highlighted
- [ ] Open ToolDetailScreen → compare button in AppBar
- [ ] Select Tool A from detail → SnackBar: "Tool selected for comparison"
- [ ] Go back, open Tool B detail → compare navigates to CompareScreen
- [ ] Dark theme: all colors correct
- [ ] Arabic mode: all labels in Arabic, layout correct
