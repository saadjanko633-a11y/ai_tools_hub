import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/chat_message.dart';
import '../services/app_service.dart';
import '../services/chat_service.dart';
import '../theme/app_colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textCtrl  = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send(ChatService service, bool isAr) {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || service.isLoading) return;
    _textCtrl.clear();
    service.sendMessage(text, isAr);
  }

  @override
  Widget build(BuildContext context) {
    final isAr    = context.watch<LangService>().isArabic;
    final c       = AppColors.of(context);
    final service = context.watch<ChatService>();

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr ? 'مساعد الذكاء الاصطناعي' : 'AI Assistant',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
              ),
            ),
            if (service.contextTool != null)
              Text(
                service.contextTool!.localName(isAr),
                style: GoogleFonts.cairo(fontSize: 11, color: kPrimary),
              ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: c.border),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: service.messages.isEmpty && !service.isLoading
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        isAr
                            ? 'اسألني عن أدوات الذكاء الاصطناعي 🤖'
                            : 'Ask me about AI tools 🤖',
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          color: c.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount:
                        service.messages.length + (service.isLoading ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (service.isLoading && i == 0) {
                        return const _LoadingDots();
                      }
                      final msgOffset = service.isLoading ? i - 1 : i;
                      final message = service.messages[
                          service.messages.length - 1 - msgOffset];
                      return _MessageBubble(message: message, colors: c);
                    },
                  ),
          ),
          _InputRow(
            controller: _textCtrl,
            isLoading: service.isLoading,
            isAr: isAr,
            colors: c,
            onSend: () => _send(service, isAr),
          ),
        ],
      ),
    );
  }
}

// ─── Input Row ────────────────────────────────────────────────────────────────
class _InputRow extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final bool isAr;
  final AppColors colors;
  final VoidCallback onSend;

  const _InputRow({
    required this.controller,
    required this.isLoading,
    required this.isAr,
    required this.colors,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: GoogleFonts.cairo(color: c.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: isAr ? 'اكتب سؤالك...' : 'Type your question...',
                  hintStyle:
                      GoogleFonts.cairo(color: c.textTertiary, fontSize: 14),
                  filled: true,
                  fillColor: c.card,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: c.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: kPrimary, width: 1.5),
                  ),
                ),
                onSubmitted: (_) => onSend(),
                maxLines: null,
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isLoading ? c.border : kPrimary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isLoading
                      ? Icons.hourglass_empty_rounded
                      : Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: isLoading ? null : onSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Message Bubble ───────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final AppColors colors;

  const _MessageBubble({required this.message, required this.colors});

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Align(
      alignment:
          message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: message.isUser ? kPrimary : c.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: message.isUser
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: message.isUser
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
          border: message.isUser ? null : Border.all(color: c.border),
        ),
        child: Text(
          message.text,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: message.isUser ? Colors.white : c.textPrimary,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

// ─── Loading Dots ─────────────────────────────────────────────────────────────
class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                final phase = ((_ctrl.value - i * 0.3) % 1.0).clamp(0.0, 1.0);
                final opacity =
                    (phase < 0.5 ? phase * 2 : 2 - phase * 2).clamp(0.3, 1.0);
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: opacity),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
