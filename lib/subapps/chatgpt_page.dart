import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oneapp/models/chat.dart';
import 'package:oneapp/services/backend/chatgpt_api.dart';
import 'package:oneapp/services/preference/app_preference.dart';
import 'package:oneapp/subapps/view_model.dart';
import 'package:provider/provider.dart';

class ChatgptPage extends StatelessWidget {
  const ChatgptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _ViewModel(
        appPref: context.read<AppPreference>(),
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
          body: viewModel.apiKey == null
              ? const _SetApiKeyView()
              : const _ChatView(),
        );
      },
    );
  }
}

class _ChatView extends StatelessWidget {
  const _ChatView();

  @override
  Widget build(BuildContext context) {
    return Consumer<_ViewModel>(
      builder: (context, viewModel, _) {
        return Column(
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
        );
      },
    );
  }
}

class _SetApiKeyView extends StatelessWidget {
  const _SetApiKeyView();

  @override
  Widget build(BuildContext context) {
    return Consumer<_ViewModel>(
      builder: (context, viewModel, _) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Welcome to Chat-GPT bot. You need a ChatGPT API key to continue.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: viewModel.apiKeyController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'sk-******************',
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.all(
                    Radius.circular(6),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                        '1. Open https://platform.openai.com/account/api-keys.'),
                    SizedBox(height: 12),
                    Text('2. Click "Create new secret key".'),
                    SizedBox(height: 12),
                    Text('3. Copy & Paste your API key.'),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: viewModel.apiKeyController.text.isEmpty
                      ? null
                      : viewModel.setApiKey,
                  child: const Text('Continue'),
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
  _ViewModel({
    required this.appPref,
    required this.api,
  });

  final AppPreference appPref;
  final ChatgptApi api;

  late final apiKeyController = TextEditingController()
    ..addListener(notifyListeners);
  final chatController = TextEditingController();

  final _chats = <Chat>[];
  List<Chat> get chats => List.unmodifiable(_chats.reversed);

  bool _sending = false;
  bool get sending => _sending;

  String? get apiKey => appPref.apiKey;

  void setApiKey() {
    final apiKey = apiKeyController.text;
    appPref.apiKey = apiKey;
    notifyListeners();
  }

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
