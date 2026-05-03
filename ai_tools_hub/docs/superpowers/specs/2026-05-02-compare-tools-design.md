# Compare Tools Feature — Design Spec
Date: 2026-05-02

## Overview

Add a side-by-side tool comparison feature to AI Tools Hub. Users select two tools via a compare button on each `ToolCard` or `ToolDetailScreen`, then view them on a dedicated `CompareScreen`.

---

## Branch

Feature branches off `refactor/split-main-dart` (not `main`). The refactor branch has the split file structure this feature builds on (`tool_card.dart`, `tool_detail_screen.dart`, etc.).

---

## CompareService

**File:** `lib/services/compare_service.dart`

Standalone file (not added to `app_service.dart`).

```dart
class CompareService extends ChangeNotifier {
  AiTool? selectedTool;
  void selectTool(AiTool tool) { selectedTool = tool; notifyListeners(); }
  void clearSelection()        { selectedTool = null; notifyListeners(); }
}
```

- No `SharedPreferences` — selection is transient (in-memory only)
- Registered in `MultiProvider` in `main.dart` without a `prefs` argument
- `clearSelection()` is called immediately after navigating to `CompareScreen` so the badge disappears on return

---

## ToolCard Modification

**File:** `lib/widgets/tool_card.dart`

Add a compare `GestureDetector` button next to the existing favorite button. Behaviour:

| State | Action |
|---|---|
| `selectedTool == null` | Set this tool as `selectedTool` |
| `selectedTool == this tool` | Show SnackBar: `"اختر أداة مختلفة" / "Choose a different tool"` |
| `selectedTool == different tool` | Navigate to `CompareScreen(tool1, tool2)`, then `clearSelection()` |

**Visual:**
- Icon: `Icons.compare_arrows_rounded`
- When this tool is selected: indigo tint background + indigo border (mirrors fav button active state pattern)
- When not selected: `c.bg` background + `c.border` border, `c.textTertiary` icon color

---

## ToolDetailScreen Modification

**File:** `lib/screens/tool_detail_screen.dart`

Add the same compare `IconButton` to the AppBar actions. Identical logic to ToolCard. Icon: `Icons.compare_arrows_rounded`. Active state: icon color switches to `kPrimary`.

---

## CompareScreen

**File:** `lib/screens/compare_screen.dart`

Accepts two `AiTool` positional parameters: `tool1`, `tool2`.

### AppBar
- Title: `"مقارنة الأدوات"` (AR) / `"Compare Tools"` (EN)
- Uses `AppColors` for background; `GoogleFonts.cairo` for title

### Layout
`SingleChildScrollView` → `Column`:

1. **Header row** — two equal columns, each showing:
   - Emoji icon in colored circle
   - Tool name (`GoogleFonts.cairo`, bold)
   - Category badge chip

2. **Comparison rows** — for each field, a `Row` with two equal cells:

   | Field | Display |
   |---|---|
   | Rating | `⭐ X.X` text |
   | Category | colored chip |
   | Free / Paid | `"مجاني" / "Free"` or `"مدفوع" / "Paid"` |
   | Has Free Plan | ✅ or ❌ icon |
   | Tags | `Wrap` of existing `TagChip` widgets |
   | Website | `OutlinedButton` → `url_launcher` |

3. **Difference highlight** — rows where `tool1` and `tool2` values differ get a subtle background: `kPrimary.withValues(alpha: 0.06)`.

### RTL/LTR
- All labels driven by `LangService.isArabic`
- Text rendered with `GoogleFonts.cairo`
- `Directionality` inherited from root (no local override needed)

### Theme
- All colors via `AppColors.of(context)` — no hardcoded colors except `kPrimary`/`kSecondary` constants

---

## Navigation

```
ToolCard (compare tap)        → CompareScreen(tool1, tool2)
ToolDetailScreen (compare tap) → CompareScreen(tool1, tool2)
```

Both use the existing slide `PageRouteBuilder` transition pattern already in the codebase.

---

## Error / Edge Cases

| Case | Handling |
|---|---|
| Same tool tapped twice | SnackBar shown, selection unchanged |
| Back from CompareScreen | `clearSelection()` already called before push; badge gone |
| url_launcher fails | Existing `canLaunchUrl` guard (same as `ToolDetailScreen`) |

---

## Files Changed

| File | Change |
|---|---|
| `lib/services/compare_service.dart` | **New** — CompareService |
| `lib/main.dart` | Add `CompareService` to `MultiProvider` |
| `lib/widgets/tool_card.dart` | Add compare button |
| `lib/screens/tool_detail_screen.dart` | Add compare IconButton in AppBar |
| `lib/screens/compare_screen.dart` | **New** — CompareScreen |

---

## Verification

- `flutter analyze` — 0 issues
- `flutter test` — all passing
- Manual test on emulator-5554: compare flow end-to-end, SnackBar, dark/light theme, AR/EN
