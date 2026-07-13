import 'package:flutter/material.dart';

class TableFieldController {
  List<List<String>> rows;

  TableFieldController({List<List<String>>? initialRows})
      : rows = initialRows == null
            ? []
            : initialRows.map((row) => List<String>.from(row)).toList();
}

class TableDataField extends StatefulWidget {
  final String title;
  final List<String> columns;
  final List<String?> suffixes;
  final TableFieldController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final ValueChanged<List<List<String>>>? onChanged;

  const TableDataField({
    super.key,
    required this.title,
    required this.columns,
    required this.suffixes,
    required this.controller,
    required this.focusNode,
    this.nextFocus,
    this.onChanged,
  });

  @override
  State<TableDataField> createState() => _TableDataFieldState();
}

class _TableDataFieldState extends State<TableDataField>
    with SingleTickerProviderStateMixin {
  late List<List<TextEditingController>> _controllers;
  late final AnimationController _blinkController;
  late final VoidCallback _focusListener;

  @override
  void initState() {
    super.initState();
    _initControllers();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: 1.0,
    );

    _focusListener = () {
      if (!mounted) return;

      if (widget.focusNode.hasFocus) {
        _blinkController.repeat(reverse: true, count: 6);
      } else {
        _blinkController.stop();
        _blinkController.value = 1.0;
      }
    };

    widget.focusNode.addListener(_focusListener);

    _blinkController.addStatusListener((status) {
      if (!mounted) return;
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _blinkController.value = 1.0;
      }
    });
  }

  void _initControllers() {
    _controllers = widget.controller.rows
        .map((row) => row.map((value) => TextEditingController(text: value)).toList())
        .toList();
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_focusListener);
    for (final rowControllers in _controllers) {
      for (final controller in rowControllers) {
        controller.dispose();
      }
    }
    _blinkController.dispose();
    super.dispose();
  }

  Future<void> _openEditor() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: _TableEditorDialog(
              columns: widget.columns,
              suffixes: widget.suffixes,
              initialRows: widget.controller.rows,
              onSave: (newRows) {
                setState(() {
                  widget.controller.rows = newRows;
                  _initControllers();
                });
                widget.onChanged?.call(newRows);
              },
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    if (saved == true && widget.nextFocus != null) {
      FocusScope.of(context).requestFocus(widget.nextFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
            Focus(
              focusNode: widget.focusNode,
              canRequestFocus: true,
              child: FadeTransition(
                opacity: _blinkController,
                child: InkWell(
                  onTap: () {
                    FocusScope.of(context).requestFocus(widget.focusNode);
                    _openEditor();
                  },
                  child: const Icon(
                    Icons.fullscreen,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.transparent),
          ),
          child: Table(
            columnWidths: Map.fromIterables(
              List.generate(widget.columns.length, (index) => index),
              List.generate(widget.columns.length, (_) => const FlexColumnWidth(1)),
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder.symmetric(
              inside: BorderSide(color: Colors.grey.shade300),
              outside: BorderSide(color: Colors.grey.shade300),
            ),
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.blue.shade50),
                children: widget.columns
                    .map(
                      (column) => Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(column, softWrap: true),
                      ),
                    )
                    .toList(),
              ),
              ...List.generate(_controllers.length, (rowIndex) {
                final rowControllers = _controllers[rowIndex];
                return TableRow(
                  children: List.generate(widget.columns.length, (columnIndex) {
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        controller: rowControllers[columnIndex],
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (value) {
                          widget.controller.rows[rowIndex][columnIndex] = value;
                          widget.onChanged?.call(widget.controller.rows);
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                          suffixText: widget.suffixes[columnIndex],
                          suffixStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _TableEditorDialog extends StatefulWidget {
  final List<String> columns;
  final List<String?> suffixes;
  final List<List<String>> initialRows;
  final ValueChanged<List<List<String>>> onSave;

  const _TableEditorDialog({
    required this.columns,
    required this.suffixes,
    required this.initialRows,
    required this.onSave,
  });

  @override
  State<_TableEditorDialog> createState() => _TableEditorDialogState();
}

class _TableEditorDialogState extends State<_TableEditorDialog> {
  late List<List<TextEditingController>> _rowControllers;

  @override
  void initState() {
    super.initState();
    _rowControllers = widget.initialRows
        .map((row) => row.map((value) => TextEditingController(text: value)).toList())
        .toList();
  }

  @override
  void dispose() {
    for (final rowControllers in _rowControllers) {
      for (final controller in rowControllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _addRow() {
    setState(() {
      _rowControllers.add(List.generate(widget.columns.length, (_) => TextEditingController()));
    });
  }

  void _removeLastRow() {
    if (_rowControllers.isEmpty) return;

    setState(() {
      final lastIndex = _rowControllers.length - 1;
      for (final controller in _rowControllers[lastIndex]) {
        controller.dispose();
      }
      _rowControllers.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Éditeur de tableau',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addRow,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: _rowControllers.isEmpty ? Colors.grey : Colors.red,
                  onPressed: _rowControllers.isEmpty ? null : _removeLastRow,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  columnWidths: Map.fromIterables(
                    List.generate(widget.columns.length, (index) => index),
                    List.generate(widget.columns.length, (_) => const FlexColumnWidth(1)),
                  ),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: TableBorder.symmetric(
                    inside: BorderSide(color: Colors.grey.shade300),
                    outside: BorderSide(color: Colors.grey.shade300),
                  ),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.blue.shade50),
                      children: widget.columns.map(
                        (column) => Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(column, softWrap: true),
                        ),
                      ).toList(),
                    ),
                    ...List.generate(_rowControllers.length, (rowIndex) {
                      final rowControllers = _rowControllers[rowIndex];
                      return TableRow(
                        children: List.generate(widget.columns.length, (columnIndex) {
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextField(
                              onTapOutside: (event) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              controller: rowControllers[columnIndex],
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                ),
                                suffixText: widget.suffixes[columnIndex],
                                suffixStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade400),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onPressed: () {
                    final rows = _rowControllers
                        .map((rowControllers) => rowControllers.map((c) => c.text).toList())
                        .toList();
                    widget.onSave(rows);
                    Navigator.pop(context, true);
                  },
                  child: const Text('Sauvegarder'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

