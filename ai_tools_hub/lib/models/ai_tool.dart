enum ToolCategory {
  writing,
  image,
  video,
  voice,
  coding,
  education,
  marketing,
  productivity,
  translation,
  design,
  dataAnalysis,
  chat,
}

extension ToolCategoryExtension on ToolCategory {
  String get nameAr {
    switch (this) {
      case ToolCategory.writing:      return 'كتابة';
      case ToolCategory.image:        return 'صور';
      case ToolCategory.video:        return 'فيديو';
      case ToolCategory.voice:        return 'صوت';
      case ToolCategory.coding:       return 'برمجة وكود';
      case ToolCategory.education:    return 'تعليم';
      case ToolCategory.marketing:    return 'تسويق';
      case ToolCategory.productivity: return 'إنتاجية';
      case ToolCategory.translation:  return 'ترجمة';
      case ToolCategory.design:       return 'تصميم';
      case ToolCategory.dataAnalysis: return 'تحليل بيانات';
      case ToolCategory.chat:         return 'دردشة';
    }
  }

  String get nameEn {
    switch (this) {
      case ToolCategory.writing:      return 'Writing';
      case ToolCategory.image:        return 'Image';
      case ToolCategory.video:        return 'Video';
      case ToolCategory.voice:        return 'Voice';
      case ToolCategory.coding:       return 'Coding';
      case ToolCategory.education:    return 'Education';
      case ToolCategory.marketing:    return 'Marketing';
      case ToolCategory.productivity: return 'Productivity';
      case ToolCategory.translation:  return 'Translation';
      case ToolCategory.design:       return 'Design';
      case ToolCategory.dataAnalysis: return 'Data Analysis';
      case ToolCategory.chat:         return 'Chat';
    }
  }

  String get emoji {
    switch (this) {
      case ToolCategory.writing:      return '✍️';
      case ToolCategory.image:        return '🖼️';
      case ToolCategory.video:        return '🎬';
      case ToolCategory.voice:        return '🎙️';
      case ToolCategory.coding:       return '💻';
      case ToolCategory.education:    return '🎓';
      case ToolCategory.marketing:    return '💼';
      case ToolCategory.productivity: return '📊';
      case ToolCategory.translation:  return '🌐';
      case ToolCategory.design:       return '🎨';
      case ToolCategory.dataAnalysis: return '📈';
      case ToolCategory.chat:         return '💬';
    }
  }
}

class AiTool {
  final String id;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final ToolCategory category;
  final String icon;
  final String url;
  final bool isFree;
  final bool hasFreePlan;
  final double rating;
  final List<String> tags;
  final bool isNew;

  const AiTool({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.category,
    required this.icon,
    required this.url,
    required this.isFree,
    required this.hasFreePlan,
    required this.rating,
    this.tags = const [],
    this.isNew = false,
  });

  String localName(bool isArabic) => isArabic ? nameAr : nameEn;
  String localDesc(bool isArabic) => isArabic ? descriptionAr : descriptionEn;

  List<String> displayTags(bool isAr) {
    final result = <String>[];
    if (isFree) {
      result.add(isAr ? 'مجاني' : 'Free');
    } else if (hasFreePlan) {
      result.add(isAr ? 'نسخة مجانية' : 'Free Plan');
    }
    if (rating >= 4.7) result.add(isAr ? 'الأعلى تقييماً' : 'Top Rated');
    for (final tag in tags) {
      result.add(_localizeTag(tag, isAr));
    }
    return result;
  }

  static String _localizeTag(String tag, bool isAr) {
    if (!isAr) return tag;
    const map = {
      'Open Source': 'مفتوح المصدر',
      'Mobile': 'موبايل',
      'Enterprise': 'مؤسسي',
      'API': 'API',
      'IDE': 'IDE',
      'Privacy': 'خصوصية',
      'No-Code': 'بدون كود',
      'Collaboration': 'تعاون',
      'Multi-Model': 'متعدد النماذج',
      'CRM': 'CRM',
      'Cloud': 'سحابي',
      'Math': 'رياضيات',
      'SEO': 'SEO',
      'Meetings': 'اجتماعات',
      'Music': 'موسيقى',
    };
    return map[tag] ?? tag;
  }
}
