import 'package:flutter/material.dart';
import 'package:oneapp/subapps/chatgpt/chatgpt_page.dart';
import 'package:oneapp/subapps/chatgpt/settings_page.dart';

class ChatgptHomePage extends StatefulWidget {
  const ChatgptHomePage({super.key});

  static const chatPage = ChatgptPage();
  static const settingsPage = SettingsPage();

  @override
  State<ChatgptHomePage> createState() => _ChatgptHomePageState();
}

class _ChatgptHomePageState extends State<ChatgptHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          ChatgptHomePage.chatPage,
          ChatgptHomePage.settingsPage
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: 'Chat-GPT',
            icon: Icon(Icons.chat_bubble_rounded),
          ),
          BottomNavigationBarItem(
            label: 'Settings',
            icon: Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
