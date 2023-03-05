import 'package:oneapp/models/chat.dart';
import 'package:oneapp/services/backend/base_api.dart';

class ChatgptApi extends BaseApi {
  Future<Chat> ask(List<Chat> chats) async {
    final response = await userHttpPost(
      'v1/chat/completions',
      {
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
