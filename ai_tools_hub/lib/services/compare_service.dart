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
