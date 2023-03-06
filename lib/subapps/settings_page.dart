import 'package:flutter/material.dart';
import 'package:oneapp/services/backend/chatgpt_api.dart';
import 'package:oneapp/services/preference/app_preference.dart';
import 'package:oneapp/subapps/view_model.dart';
import 'package:provider/provider.dart';

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
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                TextField(
                  controller: viewModel.apiKeyController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'API KEY',
                  ),
                  onSubmitted: (value) => viewModel.setApiKey(value),
                ),
              ],
            ),
          );
        },
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
