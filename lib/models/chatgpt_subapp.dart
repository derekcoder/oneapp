import 'package:flutter/material.dart';
import 'package:oneapp/models/subapp.dart';
import 'package:oneapp/subapps/chatgpt/chatgpt_home_page.dart';

class ChatGPTSubapp extends Subapp {
  ChatGPTSubapp({required super.name, required super.color});

  @override
  Widget get homePage => const ChatgptHomePage();
}
