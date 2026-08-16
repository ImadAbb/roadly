import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/beam_supports/support_classes.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/drawings/beam_drawing.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/widgets_beam_editor_pro/numeric_keypad.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/widgets_beam_editor_pro/support_type_selector.dart';

class AppuisTab extends StatefulWidget {
  final double beamLength;
  final List<BeamSupport> supports;
  final ValueChanged<BeamSupport> onSupportAdded;

  const AppuisTab({
    super.key,
    required this.beamLength,
    required this.supports,
    required this.onSupportAdded,
  });

  @override
  State<AppuisTab> createState() => _AppuisTabState();
}

class _AppuisTabState extends State<AppuisTab> {
  late final TextEditingController _positionController;
  late final FocusNode _focusNode;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _supportFormKey = GlobalKey();
  SupportType? _selectedSupportType;
  bool _hasFocus = false;
  String _encastrementSide = 'left'; // 'left' ou 'right'

  @override
  void initState() {
    super.initState();
    _positionController = TextEditingController(text: '');
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _positionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditingSupport(SupportType type) {
    setState(() {
      _selectedSupportType = type;
      _positionController.text = '';
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final formContext = _supportFormKey.currentContext;
      if (formContext != null) {
        Scrollable.ensureVisible(
          formContext,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          alignment: 0.9,
        );
        return;
      }

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });

    // Ne pas déclencher le focus (et donc le clavier) pour les encastrements
    if (type != SupportType.encastrement) {
      _focusNode.requestFocus();
    }
  }

  void _addSelectedSupport() {
    if (_selectedSupportType == null) return;

    // Pour les encastrements, définir les positions automatiquement
    if (_selectedSupportType == SupportType.encastrement) {
      if (_encastrementSide == 'left') {
        widget.onSupportAdded(
          BeamSupport(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: SupportType.encastrement,
            encastrementSide: false,
            position: 0, // Gauche
          ),
        );
      } else if (_encastrementSide == 'right') {
        widget.onSupportAdded(
          BeamSupport(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: SupportType.encastrement,
            encastrementSide: true,
            position: widget.beamLength, // Droite
          ),
        );
      }

      setState(() {
        _selectedSupportType = null;
        _encastrementSide = 'left';
        _focusNode.unfocus();
      });
      return;
    }

    // Pour les autres types d'appuis, valider la position saisie
    final raw = _positionController.text.trim();
    // Si vide ou "0.00", traiter comme 0.0
    final normalized = (raw.isEmpty || raw == '0.00') ? '0.0' : raw;
    final parsed = double.tryParse(normalized.replaceAll(',', '.'));

    if (parsed == null || parsed < 0 || parsed > widget.beamLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Position invalide. Saisis une valeur entre 0 et ${widget.beamLength.toStringAsFixed(2)} m.',
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    widget.onSupportAdded(
      BeamSupport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _selectedSupportType!,
        encastrementSide: null,
        position: parsed,
      ),
    );

    setState(() {
      _selectedSupportType = null;
      _positionController.text = '';
      _focusNode.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 35,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.black, width: 2),
              ),
              height: double.infinity,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                        ),
                      ),
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      child: const Text(
                        "Appuis",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SupportTypeSelector(
                      selectedType: _selectedSupportType,
                      onSelected: _startEditingSupport,
                    ),
                    const SizedBox(height: 12),
                    if (_selectedSupportType != null)
                      Padding(
                        key: _supportFormKey,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ajouter ${SupportTypeSelector.labelFor(_selectedSupportType!)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Si c'est un encastrement, afficher un sélecteur de côté
                              if (_selectedSupportType == SupportType.encastrement)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Placer sur quel côté ?',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _encastrementSide = 'left';
                                                    });
                                                  },
                                                  child: AnimatedContainer(
                                                    duration: const Duration(milliseconds: 150),
                                                    padding: const EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                      color: _encastrementSide == 'left'
                                                          ? Colors.grey.shade300
                                                          : Colors.white,
                                                      border: Border.all(
                                                        color: _encastrementSide == 'left'
                                                            ? Colors.black
                                                            : Colors.grey.shade400,
                                                        width: _encastrementSide == 'left' ? 2 : 1,
                                                      ),
                                                      borderRadius: BorderRadius.zero,
                                                      boxShadow: _encastrementSide == 'left'
                                                          ? [
                                                              BoxShadow(
                                                                color: Colors.black
                                                                    .withValues(alpha: 0.06),
                                                                blurRadius: 3,
                                                                offset: const Offset(0, 1),
                                                              ),
                                                            ]
                                                          : null,
                                                    ),
                                                    child: const Center(
                                                      child: Text(
                                                        'Gauche',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 12.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _encastrementSide = 'right';
                                                    });
                                                  },
                                                  child: AnimatedContainer(
                                                    duration: const Duration(milliseconds: 150),
                                                    padding: const EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                      color: _encastrementSide == 'right'
                                                          ? Colors.grey.shade300
                                                          : Colors.white,
                                                      border: Border.all(
                                                        color: _encastrementSide == 'right'
                                                            ? Colors.black
                                                            : Colors.grey.shade400,
                                                        width: _encastrementSide == 'right' ? 2 : 1,
                                                      ),
                                                      borderRadius: BorderRadius.zero,
                                                      boxShadow: _encastrementSide == 'right'
                                                          ? [
                                                              BoxShadow(
                                                                color: Colors.black
                                                                    .withValues(alpha: 0.06),
                                                                blurRadius: 3,
                                                                offset: const Offset(0, 1),
                                                              ),
                                                            ]
                                                          : null,
                                                    ),
                                                    child: const Center(
                                                      child: Text(
                                                        'Droite',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 12.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              else
                                // Pour les autres types d'appuis, afficher le champ de position
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Position (m)',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _positionController,
                                      focusNode: _focusNode,
                                      keyboardType: TextInputType.none,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                                      ],
                                      groupId: RoadlyNumericKeypad.groupId,
                                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        suffixText: 'm',
                                        hintText: '0.00',
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _addSelectedSupport,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.grey.shade300,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.all(10),
                                  ),
                                  child: const Text(
                                    'Ajouter',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 10),
                    if (widget.supports.isNotEmpty)
                      ...widget.supports.map((support) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          child: Text(
                            '- ${support.label} : ${support.position.toStringAsFixed(2)} m',
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }),
                    if (widget.supports.isEmpty) const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),

        Expanded(
          flex: 65,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _hasFocus && _selectedSupportType != null
                    ? RoadlyNumericKeypad(controller: _positionController)
                    : BeamDrawing(
                        beamLength: widget.beamLength,
                        supports: widget.supports,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
