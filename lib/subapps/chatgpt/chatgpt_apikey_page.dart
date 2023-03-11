import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:oneapp/services/backend/chatgpt_api.dart';
import 'package:oneapp/services/preference/app_preference.dart';
import 'package:oneapp/subapps/chatgpt/chatgpt_home_viewmodel.dart';
import 'package:oneapp/subapps/shared_components/view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatgptApiKeyPage extends StatelessWidget {
  const ChatgptApiKeyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _ViewModel(
        appPref: context.read<AppPreference>(),
        api: context.read<ChatgptApi>(),
        chatgptHomeViewModel: context.read<ChatgotHomeViewModel>(),
      ),
      child: const _ChatgptApiKeyView(),
    );
  }
}

class _ChatgptApiKeyView extends StatelessWidget {
  const _ChatgptApiKeyView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat-GPT')),
      body: SafeArea(
        child: Consumer<_ViewModel>(
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
        ),
      ),
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
            : () {
                final value = viewModel.apiKeyController.text;
                viewModel.apiKey = value;
              },
        child: const Text('Continue'),
      ),
    );
  }
}

class _ViewModel extends ViewModel {
  _ViewModel({
    required this.appPref,
    required this.api,
    required this.chatgptHomeViewModel,
  });

  final AppPreference appPref;
  final ChatgptApi api;
  final ChatgotHomeViewModel chatgptHomeViewModel;

  late final apiKeyController = TextEditingController()
    ..addListener(notifyListeners);

  String get apiKey => appPref.apiKey;
  set apiKey(String value) {
    appPref.apiKey = value;
    api.updateApiKey(value);
    notifyListeners();
    chatgptHomeViewModel.notifyListeners();
  }
}
