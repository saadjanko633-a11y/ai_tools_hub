import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/ai_tool.dart';
import '../models/chat_message.dart';

class ChatService extends ChangeNotifier {
  final List<ChatMessage> messages = [];
  bool isLoading = false;
  AiTool? contextTool;

  Future<void> sendMessage(String userMessage, bool isArabic) async {
    messages.add(ChatMessage(
      text: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    isLoading = true;
    notifyListeners();

    try {
      String systemPrompt = isArabic
          ? 'أنت مساعد متخصص في أدوات الذكاء الاصطناعي. تساعد المستخدمين في فهم واختيار أفضل أدوات الذكاء الاصطناعي. أجب بالعربية بشكل واضح ومختصر.'
          : 'You are an AI tools expert assistant. Help users understand and choose the best AI tools. Answer clearly and concisely.';

      if (contextTool != null) {
        systemPrompt += isArabic
            ? '\nالمستخدم يشاهد أداة: ${contextTool!.nameAr} - ${contextTool!.descriptionAr}'
            : '\nUser is viewing: ${contextTool!.nameEn} - ${contextTool!.descriptionEn}';
      }

      // All messages except the one just added (sent separately as the final user turn)
      final history = messages
          .take(messages.length - 1)
          .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
          .toList();

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $groqApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': groqModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            ...history,
            {'role': 'user', 'content': userMessage},
          ],
          'max_tokens': 1024,
        }),
      );

      final data    = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;
      final msg     = choices?.isNotEmpty == true
          ? (choices![0] as Map<String, dynamic>)['message'] as Map<String, dynamic>?
          : null;
      final content = msg?['content'] as String?;
      if (content == null || content.isEmpty) throw FormatException('Empty response from API');
      messages.add(ChatMessage(
        text: content,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } catch (_) {
      messages.add(ChatMessage(
        text: isArabic ? 'حدث خطأ. حاول مرة أخرى.' : 'An error occurred. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
