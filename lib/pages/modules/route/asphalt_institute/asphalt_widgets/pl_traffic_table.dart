import 'package:flutter/material.dart';
import '../asphalt_data.dart';
import 'package:flutter/services.dart';


class PLTrafficTable extends StatefulWidget {
  final List<PLData> data;
  final ValueChanged<List<PLData>> onSave;

  const PLTrafficTable({super.key, required this.data, required this.onSave});

  @override
  State<PLTrafficTable> createState() => _PLTrafficTableState();
}

class _PLTrafficTableState extends State<PLTrafficTable> {
  late final List<PLData> temp;
  late final List<List<TextEditingController>> _controllers;

  bool showError = false;

  double _calculateTotalPourcentage() {
    double total = 0;
    for (final pl in temp) {
      final value = double.tryParse(pl.pourcentage) ?? 0;
      total += value;
    }
    return total;
  }

  @override
  void initState() {
    super.initState();

    temp = widget.data.map((e) => e.copy()).toList();
    _controllers = temp.map((pl) {
      return [
        TextEditingController(text: pl.pourcentage),
        TextEditingController(text: pl.essieuxSimples),
        TextEditingController(text: pl.essieuxTandems),
      ];
    }).toList();
  }

  @override
  void dispose() {
    for (final rowControllers in _controllers) {
      for (final controller in rowControllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Widget _buildInput(
    TextEditingController controller,
    void Function(String) onChanged,
  ) {
    return TextField(
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.grey.shade400,
          ), // couleur quand pas focus
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 2,
          ), // couleur quand focus
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPourcentage = _calculateTotalPourcentage();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "Modifier la répartition du trafic poids lourds",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      border: TableBorder.symmetric(
                        inside: BorderSide(color: Colors.grey.shade300),
                        outside: BorderSide(color: Colors.grey.shade300),
                      ),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.blue.shade50),
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                "Pourcentage",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                "Essieux simples\n(kip)",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                "Essieux tandems\n(kip)",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        ...List.generate(temp.length, (index) {
                          final pl = temp[index];
                          final controllers = _controllers[index];

                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: TextField(
                                  controller: controllers[0],
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    pl.pourcentage =
                                        value; // stocke uniquement la valeur numérique
                                  },
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors.blue,
                                        width: 2,
                                      ),
                                    ),
                                    suffixText: "%", // 🔹 suffixe fixe
                                    suffixStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: _buildInput(controllers[1], (value) {
                                  pl.essieuxSimples = value;
                                }),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: _buildInput(controllers[2], (value) {
                                  pl.essieuxTandems = value;
                                }),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (showError) //
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "La somme des pourcentages doit être égale à 100%.",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Colors.red, // couleur du texte et de l’icône
                  ),
                  child: const Text("Annuler"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    foregroundColor:
                        Colors.blue, // couleur du texte et de l’icône
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text("Sauvegarder"),
                  onPressed: () {
                    if (totalPourcentage != 100) {
                      setState(() {
                        showError = true;
                      });

                      HapticFeedback.vibrate();

                      Future.delayed(const Duration(seconds: 4), () {
                        setState(() {
                          showError = false;
                        });
                      });
                      return;
                    }
                    widget.onSave(temp);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PLNormalTable extends StatelessWidget {
  final List<PLData> data;

  const PLNormalTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder.symmetric(
          inside: BorderSide(color: Colors.grey.shade300),
          outside: BorderSide(color: Colors.grey.shade300),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.blue.shade50),
            children: const [
              Padding(
                padding: EdgeInsets.all(12),
                child: Text("Pourcentage", softWrap: true),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Text("Essieux simples", softWrap: true),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Text("Essieux tandems", softWrap: true),
              ),
            ],
          ),
          ...data.map((pl) {
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(pl.pourcentage),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(pl.essieuxSimples),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(pl.essieuxTandems),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
