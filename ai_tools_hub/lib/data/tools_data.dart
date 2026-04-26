import 'package:flutter/material.dart';
import '../models/ai_tool.dart';

const List<String> kCategories = ['Writing', 'Image', 'Video', 'Voice'];

const List<AiTool> kAllTools = [
  // ── Writing ──────────────────────────────────────────────────────────────
  AiTool(
    id: 'chatgpt',
    nameEn: 'ChatGPT',
    nameAr: 'شات جي بي تي',
    descriptionEn: 'OpenAI\'s powerful chatbot for writing, coding, analysis, and creative tasks.',
    descriptionAr: 'روبوت دردشة قوي من OpenAI للكتابة والبرمجة والتحليل والمهام الإبداعية.',
    category: 'Writing',
    url: 'https://chat.openai.com',
  ),
  AiTool(
    id: 'claude',
    nameEn: 'Claude',
    nameAr: 'كلود',
    descriptionEn: 'Anthropic\'s AI assistant known for nuanced reasoning and long-document analysis.',
    descriptionAr: 'مساعد ذكاء اصطناعي من Anthropic، معروف بالتفكير المنطقي وتحليل الوثائق الطويلة.',
    category: 'Writing',
    url: 'https://claude.ai',
  ),
  AiTool(
    id: 'gemini',
    nameEn: 'Gemini',
    nameAr: 'جيميناي',
    descriptionEn: 'Google\'s multimodal AI that understands text, images, code, and audio natively.',
    descriptionAr: 'ذكاء اصطناعي متعدد الوسائط من Google يفهم النصوص والصور والكود والصوت بشكل طبيعي.',
    category: 'Writing',
    url: 'https://gemini.google.com',
  ),
  AiTool(
    id: 'jasper',
    nameEn: 'Jasper AI',
    nameAr: 'جاسبر',
    descriptionEn: 'Enterprise AI writing assistant for marketing copy, blogs, and brand voice.',
    descriptionAr: 'مساعد كتابة ذكاء اصطناعي للمؤسسات لمحتوى التسويق والمدونات وصوت العلامة التجارية.',
    category: 'Writing',
    url: 'https://jasper.ai',
  ),
  AiTool(
    id: 'copyai',
    nameEn: 'Copy.ai',
    nameAr: 'كوبي دوت إيه آي',
    descriptionEn: 'AI copywriting tool for social media ads, emails, and marketing content at scale.',
    descriptionAr: 'أداة كتابة نصوص ذكاء اصطناعي لإعلانات التواصل الاجتماعي والبريد والتسويق.',
    category: 'Writing',
    url: 'https://copy.ai',
  ),
  AiTool(
    id: 'writesonic',
    nameEn: 'Writesonic',
    nameAr: 'رايتسونيك',
    descriptionEn: 'AI writing platform generating SEO-optimized articles, ads, and landing pages.',
    descriptionAr: 'منصة كتابة ذكاء اصطناعي تولد مقالات محسّنة لمحركات البحث وإعلانات وصفحات هبوط.',
    category: 'Writing',
    url: 'https://writesonic.com',
  ),
  // ── Image ─────────────────────────────────────────────────────────────────
  AiTool(
    id: 'midjourney',
    nameEn: 'Midjourney',
    nameAr: 'ميدجورني',
    descriptionEn: 'Leading AI image generator known for stunning artistic and photorealistic visuals.',
    descriptionAr: 'مولد صور ذكاء اصطناعي رائد، معروف بمخرجاته الفنية والواقعية المذهلة.',
    category: 'Image',
    url: 'https://www.midjourney.com',
  ),
  AiTool(
    id: 'dalle3',
    nameEn: 'DALL·E 3',
    nameAr: 'دالي 3',
    descriptionEn: 'OpenAI\'s image generation model with precise prompt understanding and creative outputs.',
    descriptionAr: 'نموذج توليد الصور من OpenAI مع فهم دقيق للأوامر ومخرجات إبداعية متميزة.',
    category: 'Image',
    url: 'https://openai.com/dall-e-3',
  ),
  AiTool(
    id: 'stability',
    nameEn: 'Stable Diffusion',
    nameAr: 'ستيبل ديفيوجن',
    descriptionEn: 'Open-source AI image model with unparalleled flexibility and community-driven customization.',
    descriptionAr: 'نموذج صور ذكاء اصطناعي مفتوح المصدر بمرونة لا مثيل لها وتخصيص من المجتمع.',
    category: 'Image',
    url: 'https://stability.ai',
  ),
  AiTool(
    id: 'firefly',
    nameEn: 'Adobe Firefly',
    nameAr: 'أدوبي فايرفلاي',
    descriptionEn: 'Adobe\'s generative AI for creating and editing images with full commercial safety.',
    descriptionAr: 'الذكاء الاصطناعي التوليدي من Adobe لإنشاء وتحرير الصور بأمان تجاري كامل.',
    category: 'Image',
    url: 'https://firefly.adobe.com',
  ),
  AiTool(
    id: 'leonardo',
    nameEn: 'Leonardo AI',
    nameAr: 'ليوناردو',
    descriptionEn: 'AI image platform specialized in game assets, concept art, and consistent characters.',
    descriptionAr: 'منصة صور ذكاء اصطناعي متخصصة في أصول الألعاب والفن المفاهيمي والشخصيات المتسقة.',
    category: 'Image',
    url: 'https://leonardo.ai',
  ),
  AiTool(
    id: 'canva',
    nameEn: 'Canva AI',
    nameAr: 'كانفا',
    descriptionEn: 'Design platform with AI tools for image generation, background removal, and auto-layouts.',
    descriptionAr: 'منصة تصميم بأدوات ذكاء اصطناعي لتوليد الصور وإزالة الخلفيات والتخطيطات التلقائية.',
    category: 'Image',
    url: 'https://www.canva.com',
  ),
  // ── Video ─────────────────────────────────────────────────────────────────
  AiTool(
    id: 'runway',
    nameEn: 'Runway',
    nameAr: 'رانواي',
    descriptionEn: 'Professional AI video generation and editing platform used by filmmakers worldwide.',
    descriptionAr: 'منصة توليد وتحرير فيديو احترافية بالذكاء الاصطناعي يستخدمها صانعو الأفلام حول العالم.',
    category: 'Video',
    url: 'https://runwayml.com',
  ),
  AiTool(
    id: 'pika',
    nameEn: 'Pika Labs',
    nameAr: 'بيكا لابس',
    descriptionEn: 'AI video creation tool that transforms text and images into cinematic short clips.',
    descriptionAr: 'أداة إنشاء فيديو ذكاء اصطناعي تحول النصوص والصور إلى مقاطع سينمائية قصيرة.',
    category: 'Video',
    url: 'https://pika.art',
  ),
  AiTool(
    id: 'heygen',
    nameEn: 'HeyGen',
    nameAr: 'هيجن',
    descriptionEn: 'AI avatar video platform for creating professional spokesperson videos at scale.',
    descriptionAr: 'منصة فيديو أفاتار ذكاء اصطناعي لإنشاء مقاطع فيديو متحدث احترافية على نطاق واسع.',
    category: 'Video',
    url: 'https://www.heygen.com',
  ),
  AiTool(
    id: 'synthesia',
    nameEn: 'Synthesia',
    nameAr: 'سينثيسيا',
    descriptionEn: 'Create AI-powered video presentations with realistic avatars in 130+ languages.',
    descriptionAr: 'إنشاء عروض فيديو بالذكاء الاصطناعي مع أفاتارات واقعية وأكثر من 130 لغة.',
    category: 'Video',
    url: 'https://www.synthesia.io',
  ),
  AiTool(
    id: 'kling',
    nameEn: 'Kling AI',
    nameAr: 'كلينج',
    descriptionEn: 'Advanced AI video generator producing high-quality, physics-accurate video scenes.',
    descriptionAr: 'مولد فيديو ذكاء اصطناعي متقدم ينتج مقاطع عالية الجودة دقيقة فيزيائياً.',
    category: 'Video',
    url: 'https://klingai.com',
  ),
  AiTool(
    id: 'invideo',
    nameEn: 'InVideo AI',
    nameAr: 'إنفيديو',
    descriptionEn: 'AI video maker that turns text prompts into complete videos with stock footage.',
    descriptionAr: 'صانع فيديو ذكاء اصطناعي يحول النصوص إلى مقاطع فيديو كاملة مع لقطات مخزنة.',
    category: 'Video',
    url: 'https://invideo.io',
  ),
  // ── Voice ─────────────────────────────────────────────────────────────────
  AiTool(
    id: 'elevenlabs',
    nameEn: 'ElevenLabs',
    nameAr: 'إليفن لابس',
    descriptionEn: 'Industry-leading AI voice synthesis for realistic text-to-speech and voice cloning.',
    descriptionAr: 'تركيب صوت ذكاء اصطناعي رائد في الصناعة لتحويل النص إلى كلام واستنساخ الأصوات.',
    category: 'Voice',
    url: 'https://elevenlabs.io',
  ),
  AiTool(
    id: 'murf',
    nameEn: 'Murf AI',
    nameAr: 'مورف',
    descriptionEn: 'Professional AI voiceover studio with 120+ voices in 20 languages for any content.',
    descriptionAr: 'استوديو تعليق صوتي احترافي بذكاء اصطناعي مع أكثر من 120 صوتاً بـ 20 لغة.',
    category: 'Voice',
    url: 'https://murf.ai',
  ),
  AiTool(
    id: 'suno',
    nameEn: 'Suno AI',
    nameAr: 'سونو',
    descriptionEn: 'AI music generation platform that creates full songs with vocals from text prompts.',
    descriptionAr: 'منصة توليد موسيقى ذكاء اصطناعي تنشئ أغاني كاملة مع أصوات بشرية من نصوص.',
    category: 'Voice',
    url: 'https://suno.com',
  ),
  AiTool(
    id: 'udio',
    nameEn: 'Udio',
    nameAr: 'يوديو',
    descriptionEn: 'AI music creation tool for generating high-quality songs and rich instrumentals.',
    descriptionAr: 'أداة إنشاء موسيقى ذكاء اصطناعي لتوليد أغاني عالية الجودة وموسيقى آلات غنية.',
    category: 'Voice',
    url: 'https://www.udio.com',
  ),
  AiTool(
    id: 'descript',
    nameEn: 'Descript',
    nameAr: 'ديسكريبت',
    descriptionEn: 'All-in-one audio and video editor with AI transcription and voice cloning.',
    descriptionAr: 'محرر صوت وفيديو شامل مع نسخ ذكاء اصطناعي وميزات استنساخ الأصوات.',
    category: 'Voice',
    url: 'https://www.descript.com',
  ),
  AiTool(
    id: 'speechify',
    nameEn: 'Speechify',
    nameAr: 'سبيتشيفاي',
    descriptionEn: 'AI text-to-speech app that reads any content aloud at speeds up to 4.5x faster.',
    descriptionAr: 'تطبيق تحويل نص إلى كلام بذكاء اصطناعي يقرأ أي محتوى بسرعات تصل إلى 4.5 ضعف.',
    category: 'Voice',
    url: 'https://speechify.com',
  ),
];

Color categoryColor(String cat) {
  switch (cat) {
    case 'Writing': return const Color(0xFF6366F1);
    case 'Image':   return const Color(0xFFA855F7);
    case 'Video':   return const Color(0xFFEC4899);
    case 'Voice':   return const Color(0xFF06B6D4);
    default:        return const Color(0xFF6366F1);
  }
}

IconData categoryIcon(String cat) {
  switch (cat) {
    case 'Writing': return Icons.edit_rounded;
    case 'Image':   return Icons.auto_awesome_mosaic_rounded;
    case 'Video':   return Icons.movie_creation_rounded;
    case 'Voice':   return Icons.graphic_eq_rounded;
    default:        return Icons.auto_awesome_rounded;
  }
}

String categoryLabel(String cat, bool isArabic) {
  if (!isArabic) return cat;
  switch (cat) {
    case 'Writing': return 'كتابة';
    case 'Image':   return 'صور';
    case 'Video':   return 'فيديو';
    case 'Voice':   return 'صوت';
    default:        return cat;
  }
}
