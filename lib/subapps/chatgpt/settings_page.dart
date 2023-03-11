import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:oneapp/services/backend/chatgpt_api.dart';
import 'package:oneapp/services/preference/app_preference.dart';
import 'package:oneapp/subapps/shared_components/view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _ViewModel(
        appPref: context.read<AppPreference>(),
        api: context.read<ChatgptApi>(),
      ),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<_ViewModel>(
        builder: (context, viewModel, _) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  _buildApiTextField(viewModel),
                  const SizedBox(height: 20),
                  _buildInstructionView(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildApiTextField(_ViewModel viewModel) {
    return TextField(
      controller: viewModel.apiKeyController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'API KEY',
      ),
      onSubmitted: (value) => viewModel.setApiKey(value),
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
}

class _ViewModel extends ViewModel {
  _ViewModel({
    required this.appPref,
    required this.api,
  }) {
    apiKeyController = TextEditingController(text: appPref.apiKey);
  }

  final AppPreference appPref;
  final ChatgptApi api;

  late final TextEditingController apiKeyController;

  void setApiKey(String value) {
    appPref.apiKey = value;
    api.updateApiKey(value);

    notifyListeners();
  }
}
