import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:oneapp/models/message.dart';
import 'package:oneapp/services/backend/chatgpt_api.dart';
import 'package:oneapp/services/preference/app_preference.dart';
import 'package:oneapp/subapps/settings_page.dart';
import 'package:oneapp/subapps/view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
            actions: [
              if (viewModel.apiKey.isNotEmpty)
                IconButton(
                  onPressed: () {
                    final route = MaterialPageRoute(
                      builder: (_) => const SettingsPage(),
                    );
                    Navigator.push(context, route);
                  },
                  icon: const Icon(Icons.settings),
                ),
            ],
          ),
          body: SafeArea(
            child: viewModel.apiKey.isEmpty
                ? const _SetApiKeyView()
                : const _ChatView(),
          ),
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
            _buildChatInputView(viewModel),
            Expanded(
              child: _buildMessagesList(context, viewModel),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessagesList(BuildContext context, _ViewModel viewModel) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: viewModel.messages.length,
      itemBuilder: (context, index) {
        final message = viewModel.messages[index];
        return ListTile(
          leading: SizedBox(
            width: 64,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Text(
                  message.role.name,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    DateFormat.Hms().format(message.date),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        ?.copyWith(color: Colors.grey),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: message.content.trim()),
                      );
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Copied to clipboard"),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                  ),
                ],
              ),
              Text(message.content.trim()),
            ],
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  Widget _buildChatInputView(_ViewModel viewModel) {
    return Row(
      children: [
        const SizedBox(width: 20),
        Expanded(
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
        SizedBox(
          width: 40,
          child: viewModel.sending
              ? const CupertinoActivityIndicator()
              : IconButton(
                  onPressed: viewModel.chatController.text.isEmpty
                      ? null
                      : viewModel.sendMessage,
                  icon: const Icon(Icons.send_rounded),
                ),
        ),
        const SizedBox(width: 8),
      ],
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
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Welcome to Chat-GPT bot. You need a Chat-GPT API key to continue.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),
                    _buildApiKeyTextField(viewModel),
                    const SizedBox(height: 20),
                    _buildInstructionView(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              _buildContinueButton(viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildApiKeyTextField(_ViewModel viewModel) {
    return TextField(
      controller: viewModel.apiKeyController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'sk-******************',
      ),
    );
  }

  Widget _buildInstructionView(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: const BorderRadius.all(
          Radius.circular(6),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge,
              children: [
                const TextSpan(text: '1. Open '),
                TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      await launchUrl(
                        Uri.parse(
                            'https://platform.openai.com/account/api-keys'),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  text: 'https://platform.openai.com/account/api-keys',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '2. Click "Create new secret key"',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Text(
            '3. Copy & Paste your API key',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(_ViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: viewModel.apiKeyController.text.isEmpty
            ? null
            : viewModel.setApiKey,
        child: const Text('Continue'),
      ),
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
  late final chatController = TextEditingController()
    ..addListener(notifyListeners);

  final _messages = <Message>[];
  List<Message> get messages => List.unmodifiable(_messages.reversed);

  bool _sending = false;
  bool get sending => _sending;

  String get apiKey => appPref.apiKey;

  void setApiKey() {
    final apiKey = apiKeyController.text;
    appPref.apiKey = apiKey;
    api.updateApiKey(apiKey);

    notifyListeners();
  }

  Future<void> sendMessage() async {
    final content = chatController.text;
    final question = Message(
      role: Role.user,
      content: content,
      date: DateTime.now(),
    );
    _messages.add(question);
    chatController.text = '';
    _sending = true;

    notifyListeners();

    final answer = await api.send(_messages);
    _messages.add(answer);
    _sending = false;
    notifyListeners();
  }
}
