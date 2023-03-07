import 'package:flutter/material.dart';
import 'package:oneapp/models/chatgpt_subapp.dart';
import 'package:oneapp/models/subapp.dart';

class SubappRepository extends ChangeNotifier {
  SubappRepository() {
    _init();
  }

  final _subapps = <Subapp>[];
  List<Subapp> get subapps => List.unmodifiable(_subapps);

  void _init() {
    _subapps.addAll([
      ChatGPTSubapp(
        name: 'Chat-GPT',
        color: Colors.black,
      ),
    ]);
  }
}
