import 'package:flutter/material.dart';

class FormFieldConfig {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final FocusNode focusNode;
  FocusNode? nextFocus;

  FormFieldConfig({
    required this.label,
    required this.icon,
    required this.controller,
    required this.focusNode,
    this.nextFocus,
  });
}

class FieldGroup {
  final String title;
  final IconData icon;
  final List<FormFieldConfig> fields;

  FieldGroup({
    required this.title,
    required this.icon,
    required this.fields,
  });
}
