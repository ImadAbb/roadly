import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/route/route_widgets/table_data.dart';

abstract class FieldGroupItem {}

class FormFieldConfig extends FieldGroupItem {
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

class TableFieldConfig extends FieldGroupItem {
  final String label;
  final List<String> columns;
  final List<String?> suffixes;
  final TableFieldController controller;
  final FocusNode focusNode;
  FocusNode? nextFocus;
  final ValueChanged<List<List<String>>>? onChanged;

  TableFieldConfig({
    required this.label,
    required List<String> columns,
    List<String?>? suffixes,
    List<List<String>>? initialRows,
    TableFieldController? controller,
    FocusNode? focusNode,
    this.onChanged,
  })  : assert(columns.isNotEmpty, 'columns cannot be empty'),
        assert(suffixes == null || suffixes.length == columns.length,
            'suffixes length must match columns length'),
        columns = List.unmodifiable(columns),
        suffixes = List.unmodifiable(
          suffixes ?? List<String?>.filled(columns.length, null),
        ),
        controller = controller ?? TableFieldController(initialRows: initialRows),
        focusNode = focusNode ?? FocusNode();

  Widget build(BuildContext context) {
    return TableDataField(
      title: label,
      columns: columns,
      suffixes: suffixes,
      controller: controller,
      focusNode: focusNode,
      nextFocus: nextFocus,
      onChanged: onChanged,
    );
  }
}

class FieldGroup {
  final String title;
  final IconData icon;
  final List<FieldGroupItem> fields;

  FieldGroup({
    required this.title,
    required this.icon,
    required this.fields,
  });
}
