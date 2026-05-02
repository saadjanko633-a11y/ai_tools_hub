import 'package:flutter/material.dart';
import '../models/ai_tool.dart';

class CompareService extends ChangeNotifier {
  AiTool? _selectedTool;
  AiTool? get selectedTool => _selectedTool;

  void selectTool(AiTool tool) {
    _selectedTool = tool;
    notifyListeners();
  }

  void clearSelection() {
    if (_selectedTool == null) return;
    _selectedTool = null;
    notifyListeners();
  }
}
