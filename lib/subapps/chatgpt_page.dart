import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oneapp/models/chat.dart';
import 'package:oneapp/services/backend/chatgpt_api.dart';
import 'package:oneapp/subapps/view_model.dart';
import 'package:provider/provider.dart';

class ChatgptPage extends StatelessWidget {
  const ChatgptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _ViewModel(
        api: context.read<ChatgptApi>(),
      ),
      child: const _ChatgptView(),
    );
  }
}

class _ChatgptView extends StatelessWidget {
  const _ChatgptView();

  @override
  Widget build(BuildContext context) {
    return Consumer<_ViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Chat-GPT'),
          ),
          body: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      child: TextField(
                        enabled: !viewModel.sending,
                        textCapitalization: TextCapitalization.sentences,
                        controller: viewModel.chatController,
                        decoration: const InputDecoration(
                          // border: OutlineInputBorder(),
                          hintText: 'Write a message...',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: viewModel.sending
                        ? const CupertinoActivityIndicator()
                        : IconButton(
                            onPressed: () => viewModel.askQuestion(),
                            icon: const Icon(Icons.send_rounded),
                          ),
                  ),
                ],
              ),
              // const Divider(),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: viewModel.chats.length,
                  itemBuilder: (context, index) {
                    final chat = viewModel.chats[index];
                    return ListTile(
                      leading: SizedBox(
                        width: 70,
                        child: Text(
                          chat.role.name,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      title: Text(chat.content),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ViewModel extends ViewModel {
  _ViewModel({required this.api});

  final ChatgptApi api;

  final chatController = TextEditingController();

  final _chats = <Chat>[];
  List<Chat> get chats => List.unmodifiable(_chats.reversed);

  bool _sending = false;
  bool get sending => _sending;

  Future<void> askQuestion() async {
    final content = chatController.text;
    final question = Chat(role: Role.user, content: content);
    _chats.add(question);
    chatController.text = '';
    _sending = true;

    notifyListeners();

    final answer = await api.ask(_chats);
    _chats.add(answer);
    _sending = false;
    notifyListeners();
  }
}
