class AiTool {
  final String id;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final String category;
  final String url;

  const AiTool({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.category,
    required this.url,
  });

  String localName(bool isArabic) => isArabic ? nameAr : nameEn;
  String localDesc(bool isArabic) => isArabic ? descriptionAr : descriptionEn;
}
