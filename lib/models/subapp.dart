import 'package:flutter/material.dart';

abstract class Subapp {
  Subapp({
    required this.name,
    required this.color,
  });

  final String name;
  final Color color;
}
