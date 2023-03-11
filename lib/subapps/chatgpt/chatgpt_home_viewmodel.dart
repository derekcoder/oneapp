import 'package:flutter/material.dart';
import 'package:oneapp/services/preference/app_preference.dart';
import 'package:oneapp/subapps/chatgpt/chatgpt_page.dart';
import 'package:oneapp/subapps/chatgpt/settings_page.dart';
import 'package:oneapp/subapps/shared_components/view_model.dart';

class ChatgotHomeViewModel extends ViewModel {
  ChatgotHomeViewModel({required this.appPref});

  final AppPreference appPref;

  static const List<Widget> pages = [ChatgptPage(), SettingsPage()];
  static const List<BottomNavigationBarItem> navBarItems = [
    BottomNavigationBarItem(
      label: 'Chat-GPT',
      icon: Icon(Icons.chat_bubble_rounded),
    ),
    BottomNavigationBarItem(
      label: 'Settings',
      icon: Icon(Icons.settings),
    ),
  ];

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  set currentIndex(int value) {
    _currentIndex = value;
    notifyListeners();
  }

  bool get isApiKeySaved {
    print(appPref.apiKey);
    return appPref.apiKey.isNotEmpty;
  }
}
