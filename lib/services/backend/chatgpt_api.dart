import 'package:oneapp/models/chat.dart';

import 'backend_query.dart';

class ChatgptApi {
  ChatgptApi(this._apiKey);

  String _apiKey = '';

  void updateApiKey(String value) => _apiKey = value;

  Future<Chat> ask(List<Chat> chats) async {
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
    final chat = Chat.fromJson(choices.first['message']);
    return chat;
  }
}
