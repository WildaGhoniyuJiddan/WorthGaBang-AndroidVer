import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_client.dart';
import 'chat_models.dart';

final chatApiProvider = Provider<ChatApi>(
  (ref) => ChatApi(ref.watch(apiClientProvider)),
);

/// API chatbot Bang Worth (B7 POST /api/v1/chat/ask).
class ChatApi {
  ChatApi(this._client);

  final ApiClient _client;

  Future<ChatReply> ask(
    String message, {
    List<ChatMessage> history = const [],
  }) async {
    final json = await _client.postJson('/api/v1/chat/ask', body: {
      'message': message,
      'history': history.map((m) => m.toJson()).toList(),
    });
    return ChatReply.fromJson(json);
  }
}
