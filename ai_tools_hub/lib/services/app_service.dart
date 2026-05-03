import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/tools_data.dart';
import '../models/ai_tool.dart';

class LangService extends ChangeNotifier {
  static const _key = 'lang_arabic';
  final SharedPreferences _prefs;
  late bool _isArabic;

  LangService(this._prefs) {
    _isArabic = _prefs.getBool(_key) ?? true;
  }

  bool get isArabic => _isArabic;

  void toggle() {
    _isArabic = !_isArabic;
    _prefs.setBool(_key, _isArabic);
    notifyListeners();
  }
}

class FavService extends ChangeNotifier {
  static const _key = 'favorites_v2';
  final SharedPreferences _prefs;
  late Set<String> _ids;

  FavService(this._prefs) {
    final saved = _prefs.getStringList(_key);
    _ids = saved != null ? Set<String>.from(saved) : {};
  }

  bool isFav(String id) => _ids.contains(id);

  List<AiTool> get favorites =>
      kAllTools.where((t) => _ids.contains(t.id)).toList();

  void toggle(String id) {
    _ids.contains(id) ? _ids.remove(id) : _ids.add(id);
    _prefs.setStringList(_key, _ids.toList());
    notifyListeners();
  }
}

class ThemeService extends ChangeNotifier {
  static const _key = 'theme_mode';
  final SharedPreferences _prefs;
  late ThemeMode _mode;

  ThemeService(this._prefs) {
    final saved = _prefs.getInt(_key) ?? 0;
    _mode = ThemeMode.values[saved.clamp(0, ThemeMode.values.length - 1)];
  }

  ThemeMode get mode => _mode;

  void setMode(ThemeMode mode) {
    _mode = mode;
    _prefs.setInt(_key, mode.index);
    notifyListeners();
  }
}

class ViewCountService extends ChangeNotifier {
  static const _key = 'view_counts_v1';
  final SharedPreferences _prefs;
  late Map<String, int> _counts;

  ViewCountService(this._prefs) {
    final saved = _prefs.getString(_key);
    if (saved != null) {
      try {
        final decoded = json.decode(saved) as Map<String, dynamic>;
        _counts = decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
      } catch (_) {
        _counts = {};
      }
    } else {
      _counts = {};
    }
  }

  int getCount(String id) => _counts[id] ?? 0;

  void increment(String id) {
    _counts[id] = (_counts[id] ?? 0) + 1;
    try {
      _prefs.setString(_key, json.encode(_counts));
    } catch (_) {}
    notifyListeners();
  }
}

class RecentService extends ChangeNotifier {
  static const _key = 'recent_tools_v1';
  static const _maxItems = 10;
  final SharedPreferences _prefs;
  late List<String> _ids;

  RecentService(this._prefs) {
    _ids = _prefs.getStringList(_key) ?? [];
  }

  List<String> get recentIds => List.unmodifiable(_ids);

  List<AiTool> get recentTools {
    return _ids
        .map((id) {
          try {
            return kAllTools.firstWhere((t) => t.id == id);
          } catch (_) {
            return null;
          }
        })
        .whereType<AiTool>()
        .toList();
  }

  void add(String id) {
    _ids.remove(id);
    _ids.insert(0, id);
    if (_ids.length > _maxItems) _ids = _ids.sublist(0, _maxItems);
    try {
      _prefs.setStringList(_key, _ids);
    } catch (_) {}
    notifyListeners();
  }

  void clear() {
    _ids = [];
    _prefs.remove(_key);
    notifyListeners();
  }
}
