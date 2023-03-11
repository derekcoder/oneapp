import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:oneapp/models/message.dart';
import 'package:oneapp/services/backend/backend_exception.dart';
import 'package:oneapp/services/backend/chatgpt_api.dart';
import 'package:oneapp/services/preference/app_preference.dart';
import 'package:oneapp/subapps/shared_components/view_model.dart';
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
        viewModel.onApiIssue =
            (message) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                  ),
                );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chat-GPT'),
            leading: viewModel.apiKey.isEmpty
                ? null
                : IconButton(
                    onPressed:
                        viewModel.messages.isEmpty ? null : viewModel.clear,
                    icon: const Icon(Icons.delete),
                  ),
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
      controller: viewModel.scrollController,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: viewModel.messages.length,
      itemBuilder: (context, index) {
        final message = viewModel.messages[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    message.role.name,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const Text(' · '),
                  Text(
                    DateFormat.Hms().format(message.date),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
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
              MarkdownBody(
                data: message.content.trim(),
                styleSheet: MarkdownStyleSheet(
                  p: Theme.of(context).textTheme.bodyText2,
                  codeblockPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  codeblockDecoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color ??
                        Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  Widget _buildChatInputView(_ViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(left: 6, right: 6, top: 6),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey[400]!,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(4),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              enabled: !viewModel.sending,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.send,
              controller: viewModel.chatController,
              onSubmitted: (value) async {
                final content = value.trim();
                if (content.isNotEmpty) {
                  await viewModel.sendMessage(content);
                }
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Write a message...',
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: viewModel.sending
                ? const CupertinoActivityIndicator()
                : IconButton(
                    onPressed: viewModel.chatController.text.trim().isEmpty
                        ? null
                        : () async {
                            final content =
                                viewModel.chatController.text.trim();
                            if (content.isNotEmpty) {
                              await viewModel.sendMessage(content);
                            }
                          },
                    icon: const Icon(Icons.send_rounded),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
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

  void Function(String)? onApiIssue;

  late final apiKeyController = TextEditingController()
    ..addListener(notifyListeners);
  late final chatController = TextEditingController()
    ..addListener(notifyListeners);

  final scrollController = ScrollController();

  void scrollToTop() {
    if (scrollController.hasClients) {
      final position = scrollController.position.minScrollExtent;
      scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

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

  void clear() {
    _messages.clear();
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    chatController.text = '';

    final message = Message(
      role: Role.user,
      content: content,
      date: DateTime.now(),
    );

    _messages.add(message);
    _sending = true;
    notifyListeners();

    scrollToTop();

    final answer = await _send(_messages);

    if (answer != null) {
      _messages.add(answer);
    }
    _sending = false;
    notifyListeners();

    scrollToTop();
  }

  Future<Message?> _send(List<Message> messages) async {
    try {
      final answer = await api.send(messages);
      return answer;
    } on BackendException catch (e) {
      final String message;
      switch (e.type) {
        case BackendExceptionType.networkIssue:
          message = 'Got an internet issue';
          break;
        case BackendExceptionType.unauthorized:
          message = 'Unauthorized';
          break;
        case BackendExceptionType.internalError:
          message = 'Something errors happen in server';
          break;
        case BackendExceptionType.unknown:
          message = 'There is unknown error';
          break;
      }
      onApiIssue?.call(message);
    }

    return null;
  }

  Future<Message?> _translate(Message message) async {
    try {
      final answer = await api.translate(message);
      return answer;
    } on BackendException catch (e) {
      final String message;
      switch (e.type) {
        case BackendExceptionType.networkIssue:
          message = 'Got an internet issue';
          break;
        case BackendExceptionType.unauthorized:
          message = 'Unauthorized';
          break;
        case BackendExceptionType.internalError:
          message = 'Something errors happen in server';
          break;
        case BackendExceptionType.unknown:
          message = 'There is unknown error';
          break;
      }
      onApiIssue?.call(message);
    }

    return null;
  }
}