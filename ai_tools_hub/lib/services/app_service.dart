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
