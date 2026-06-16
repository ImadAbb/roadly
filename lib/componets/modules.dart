import 'package:flutter/material.dart';

class Modules {
  final String name;
  final String lastUpdate;
  final IconData icon;
  final Widget page;
  final String? descreption;

  Modules({
    required this.name,
    required this.lastUpdate,
    required this.icon,
    required this.page, 
    this.descreption,
  });
}
