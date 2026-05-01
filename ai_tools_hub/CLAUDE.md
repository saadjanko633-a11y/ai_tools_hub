# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run on Android emulator
flutter run -d emulator-5554

# Hot reload while running (in the flutter run session)
# Press 'r' for hot reload, 'R' for hot restart

# Analyze for lint/type errors
flutter analyze

# Run tests
flutter test
flutter test test/widget_test.dart   # single file

# Build APKs
flutter build apk --debug
flutter build apk --release
flutter build apk --split-per-abi --release

# Regenerate launcher icons (after changing assets/icon/app_icon.png)
dart run flutter_launcher_icons

# Regenerate splash screen
dart run flutter_native_splash:create

# Install dependencies
flutter pub get
```

## Architecture

The app is a Flutter directory of 100 AI tools with bilingual support (Arabic/English) and light/dark theming.

### State Management — Provider

Three `ChangeNotifier` services live in `lib/services/app_service.dart` and are wired at the root via `MultiProvider` in `main()`:

| Service | Key | What it does |
|---|---|---|
| `LangService` | `lang_arabic` | Toggles AR ↔ EN; drives `Directionality` (RTL/LTR) for the whole app |
| `FavService` | `favorites_v2` | Stores favorite tool IDs; exposes filtered `List<AiTool>` |
| `ThemeService` | `theme_mode` | Persists `ThemeMode` (light/dark/system) index |

`MyApp` uses `Consumer2<LangService, ThemeService>` so that `themeMode`, `theme`, and `darkTheme` are always in sync. Language direction is applied via `MaterialApp.builder` wrapping the whole widget tree in `Directionality`.

### Data Layer

All 100 tools are declared as compile-time `const` in `lib/data/tools_data.dart` (`kAllTools`). There is no network/database layer — the data is static.

`lib/models/ai_tool.dart` defines:
- `AiTool` — the tool entity (`id`, `nameEn/Ar`, `descriptionEn/Ar`, `category`, `icon` emoji, `url`, `isFree`, `hasFreePlan`, `rating`, `tags`, `isNew`)
- `ToolCategory` enum (12 categories) with `.nameAr`, `.nameEn`, `.emoji` extensions
- `displayTags(bool isAr)` — auto-generates chip labels from `isFree`/`hasFreePlan`/`rating >= 4.7` plus the stored `tags` list; `tags` are stored as English keys and localized via `_localizeTag()`
- Tools with `isNew: true` are ids 91–100 (Chatsonic, Inflection AI, Grammarly, QuillBot, Playground AI, Bing Image Creator, Amazon Q Developer, Phind, Meta AI, Cohere)

### Theme System

**Static colors:** `kPrimary = 0xFF6366F1` (indigo), `kSecondary = 0xFF8B5CF6` (purple) — used in gradients and accents everywhere.

**Dynamic colors:** `AppColors.of(context)` reads `Theme.of(context).brightness` and returns an `AppColors` instance with `bg`, `card`, `surface`, `border`, `textPrimary`, `textSecondary`, `textTertiary`. Always call `AppColors.of(context)` inside `build()` — never cache it above `build()`.

`_lightTheme()` / `_darkTheme()` in `main.dart` build the `ThemeData` objects including `NavigationBarThemeData` with `WidgetStateProperty` for icon/label colors. The `_AppScheme` class in `settings_screen.dart` is a local duplicate of this pattern used only within that file.

### Screens

All UI lives in `lib/main.dart` except the Settings screen:

- **`HomeScreen`** — `Scaffold` with `_HubAppBar` + `IndexedStack` (3 tabs) + `NavigationBar`
- **`ToolsListScreen`** — stateful; holds search query, active `ToolCategory?`, and `SortOrder`; `_filtered()` applies filter + sort over `kAllTools`; `_buildSortButton()` returns a `PopupMenuButton<SortOrder>` with 4 options (Default / Name A-Z / Rating Top / Newest First)
- **`FavoritesScreen`** — reads `FavService.favorites`; shows empty state when none
- **`ToolCard`** — card widget; shows NEW badge overlay when `tool.isNew`, tag chips via `tool.displayTags(isAr)`
- **`ToolDetailScreen`** — pushed via `Navigator.push`; shows hero icon, star rating, tags, "Open in Browser" via `url_launcher`
- **`SettingsScreen`** (`lib/screens/settings_screen.dart`) — language Switch, theme chips (Light/Dark/System), app info, share via `share_plus`

### Adding a New Tool

Add a `const AiTool(...)` entry to the correct category section in `lib/data/tools_data.dart`. Fields:
- Set `isNew: true` if it should show the NEW badge
- `tags` accepts English keys that are in `_localizeTag()`'s map: `'Open Source'`, `'Mobile'`, `'Enterprise'`, `'API'`, `'IDE'`, `'Privacy'`, `'No-Code'`, `'Collaboration'`, `'Multi-Model'`, `'CRM'`, `'Cloud'`, `'Math'`, `'SEO'`, `'Meetings'`, `'Music'`

### Adding a New Tag Key

1. Add the English key to `AiTool.tags` in `tools_data.dart`
2. Add the AR translation to the `map` in `AiTool._localizeTag()` in `ai_tool.dart`

### Font

All text uses `GoogleFonts.cairo(...)`. Do not use `TextStyle` directly — always go through `GoogleFonts.cairo`.
