import 'package:flutter/material.dart';
import 'package:oneapp/services/preference/app_preference.dart';
import 'package:oneapp/subapps/chatgpt/chatgpt_apikey_page.dart';
import 'package:oneapp/subapps/chatgpt/chatgpt_home_viewmodel.dart';
import 'package:provider/provider.dart';

class ChatgptHomePage extends StatelessWidget {
  const ChatgptHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatgotHomeViewModel(
        appPref: context.read<AppPreference>(),
      ),
      child: const _ChatgptHomeView(),
    );
  }
}

class _ChatgptHomeView extends StatelessWidget {
  const _ChatgptHomeView();

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatgotHomeViewModel>(builder: (context, viewModel, _) {
      return Scaffold(
        body: viewModel.isApiKeySaved
            ? IndexedStack(
                index: viewModel.currentIndex,
                children: ChatgotHomeViewModel.pages,
              )
            : const ChatgptApiKeyPage(),
        bottomNavigationBar: viewModel.isApiKeySaved
            ? BottomNavigationBar(
                currentIndex: viewModel.currentIndex,
                onTap: (index) => viewModel.currentIndex = index,
                items: ChatgotHomeViewModel.navBarItems,
              )
            : null,
      );
    });
  }
}
