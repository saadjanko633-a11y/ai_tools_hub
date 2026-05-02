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
