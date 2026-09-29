import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/rupiah.dart';
import '../../../core/widgets/tilt_card.dart';
import '../../../l10n/strings.dart';
import '../../profile/data/profile_api.dart';
import '../data/chat_api.dart';
import '../data/chat_models.dart';

/// Layar chat Bang Worth: bubble chat + kartu rakitan (build card)
/// bila balasan menyertakan build.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_Bubble> _bubbles = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _bubbles.add(const _Bubble(
      role: 'assistant',
      text: AppStrings.chatWelcome,
    ));
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;
    FocusScope.of(context).unfocus();
    final history = _bubbles
        .where((b) => b.text.isNotEmpty)
        .map((b) => ChatMessage(role: b.role, text: b.text))
        .toList();
    setState(() {
      _bubbles.add(_Bubble(role: 'user', text: text));
      _sending = true;
      _input.clear();
    });
    _scrollDown();
    try {
      final reply =
          await ref.read(chatApiProvider).ask(text, history: history);
      if (!mounted) return;
      setState(() {
        _bubbles.add(
            _Bubble(role: 'assistant', text: reply.reply, build: reply.build));
        _sending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _bubbles.add(_Bubble(
            role: 'assistant',
            text: '${AppStrings.chatError}: $e'));
        _sending = false;
      });
    }
    _scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.chatTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(12),
                itemCount: _bubbles.length + (_sending ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i >= _bubbles.length) {
                    return const _TypingBubble();
                  }
                  final tiltEnabled = ref
                      .watch(settingsControllerProvider)
                      .orDefault
                      .tiltEnabled;
                  return _ChatBubble(
                      bubble: _bubbles[i], tiltEnabled: tiltEnabled);
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      decoration: const InputDecoration(
                        hintText: AppStrings.chatHint,
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _send(),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble {
  const _Bubble({required this.role, required this.text, this.build});

  final String role;
  final String text;
  final BuildCardData? build;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.bubble, this.tiltEnabled = true});

  final _Bubble bubble;
  final bool tiltEnabled;

  @override
  Widget build(BuildContext context) {
    final isUser = bubble.role == 'user';
    final color = isUser
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bubble.text),
            if (bubble.build != null) ...[
              const SizedBox(height: 8),
              _BuildCard(data: bubble.build!, tiltEnabled: tiltEnabled),
            ],
          ],
        ),
      ),
    );
  }
}

/// Kartu rakitan dari chatbot — miring mengikuti gyroscope (TiltCard).
class _BuildCard extends StatelessWidget {
  const _BuildCard({required this.data, this.tiltEnabled = true});

  final BuildCardData data;
  final bool tiltEnabled;

  @override
  Widget build(BuildContext context) {
    return TiltCard(
      enabled: tiltEnabled,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.handyman_outlined, size: 16),
                  SizedBox(width: 4),
                  Text(AppStrings.buildCardTitle,
                      style:
                          TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              for (final item in data.items)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.component}: ${item.name}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        formatRupiah(item.price),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              const Divider(),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(AppStrings.totalLabel,
                      style:
                          TextStyle(fontWeight: FontWeight.bold)),
                  Text(formatRupiah(data.total),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold)),
                ],
              ),
              if (data.note != null) ...[
                const SizedBox(height: 4),
                Text(data.note!,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
