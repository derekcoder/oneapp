import 'package:oneapp/models/message.dart';

import 'backend_query.dart';

class ChatgptApi {
  ChatgptApi(this._apiKey);

  String _apiKey = '';

  void updateApiKey(String value) => _apiKey = value;

  Future<Message> send(List<Message> chats) async {
    final response = await BackendQuery.httpPost(
      'v1/chat/completions',
      apiKey: _apiKey,
      parameters: {
        'model': 'gpt-3.5-turbo',
        'stream': false,
        'messages': [
          ...chats.map((e) => e.toJson()),
        ]
      },
    );

    final choices = response['choices'] as List<dynamic>;
    final chat = Message.fromJson(choices.first['message']);
    return chat;
  }

  Future<Message> translate(Message message) async {
    final response = await BackendQuery.httpPost(
      'v1/chat/completions',
      apiKey: _apiKey,
      parameters: {
        'model': 'gpt-3.5-turbo',
        'stream': false,
        'messages': [
          {
            "content":
                "Translate every sentence in English or Simplified Chinese",
            "role": "system"
          },
          message.toJson(),
        ]
      },
    );

    final choices = response['choices'] as List<dynamic>;
    final chat = Message.fromJson(choices.first['message']);
    return chat;
  }
}
