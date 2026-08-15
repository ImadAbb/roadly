import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Couleurs par défaut du clavier, alignées sur le thème light de Roadly.
/// Tu peux les override via les paramètres du widget si un module a besoin
/// d'une autre teinte (ex: gold pour Route, green pour Ponts).
class RoadlyKeypadColors {
  final Color background;
  final Color foreground;
  final Color border;
  final Color deleteBackground;
  final Color deleteForeground;

  const RoadlyKeypadColors({
    this.background = Colors.white,
    this.foreground = const Color(0xFF1E293B),
    this.border = const Color(0xFFE2E8F0),
    this.deleteBackground = const Color(0xFFFEF2F2),
    this.deleteForeground = const Color(0xFFEF4444),
  });
}

/// Clavier numérique custom réutilisable, style calculatrice (touches
/// carrées, relief léger, feedback au tap), pour champs sans clavier natif
/// (ex: `keyboardType: TextInputType.none`).
///
/// Le clavier se dimensionne toujours pour tenir exactement dans l'espace
/// disponible (largeur ET hauteur) : jamais de scroll, jamais de débordement.
///
/// ## Important : à coupler avec `onTapOutside` du TextField
///
/// Comme ce clavier n'est pas affiché juste au-dessus du `TextField` (il
/// prend la place d'un autre widget ailleurs dans l'écran, ex: le dessin de
/// la poutre), un `TextField.onTapOutside` classique considérerait un tap
/// sur le clavier comme "en dehors du champ" et fermerait le clavier avant
/// même que la touche ne s'enregistre.
///
/// Pour éviter ça, passe [RoadlyNumericKeypad.groupId] au `groupId` du
/// `TextField` associé : les deux widgets seront alors traités comme une
/// seule zone, et seul un vrai tap en dehors des deux fermera le champ.
///
/// ```dart
/// TextField(
///   controller: _controller,
///   focusNode: _focusNode,
///   keyboardType: TextInputType.none,
///   groupId: RoadlyNumericKeypad.groupId, // 👈 indispensable
///   onTapOutside: (event) => FocusScope.of(context).unfocus(),
/// )
///
/// // ailleurs dans le même écran :
/// RoadlyNumericKeypad(controller: _controller)
/// ```
///
/// Ou en mode callback si tu gères le texte toi-même :
///
/// ```dart
/// RoadlyNumericKeypad(
///   onInsert: (value) => setState(() => _text += value),
///   onDelete: () => setState(() => _text = _text.substring(0, _text.length - 1)),
/// )
/// ```
class RoadlyNumericKeypad extends StatelessWidget {
  /// À passer tel quel au `groupId` du `TextField` associé, pour que les
  /// taps sur ce clavier ne soient jamais considérés comme "en dehors" du
  /// champ (voir la doc de la classe).
  static const Object groupId = 'roadly_numeric_keypad';

  /// Si fourni, le clavier insère/supprime directement dans ce controller.
  final TextEditingController? controller;

  /// Callback appelé à chaque insertion (ignoré si [controller] est fourni).
  final ValueChanged<String>? onInsert;

  /// Callback appelé à la suppression (ignoré si [controller] est fourni).
  final VoidCallback? onDelete;

  /// Autorise la virgule décimale. Une seule à la fois est acceptée.
  final bool allowComma;

  /// Autorise le signe moins (utile pour moments, efforts, etc.).
  final bool allowMinus;

  final RoadlyKeypadColors colors;
  final double spacing;
  final bool haptics;

  const RoadlyNumericKeypad({
    super.key,
    this.controller,
    this.onInsert,
    this.onDelete,
    this.allowComma = true,
    this.allowMinus = false,
    this.colors = const RoadlyKeypadColors(),
    this.spacing = 10,
    this.haptics = true,
  }) : assert(
          controller != null || (onInsert != null && onDelete != null),
          'Fournis soit un controller, soit onInsert + onDelete.',
        );

  void _insert(String value) {
    if (haptics) HapticFeedback.selectionClick();

    if (controller != null) {
      final current = controller!.text;
      if (value == "," && current.contains(",")) return;
      if (value == "-" && current.contains("-")) return;

      final text = current + value;
      controller!.text = text;
      controller!.selection = TextSelection.fromPosition(
        TextPosition(offset: text.length),
      );
    } else {
      onInsert?.call(value);
    }
  }

  void _delete() {
    if (haptics) HapticFeedback.selectionClick();

    if (controller != null) {
      final current = controller!.text;
      if (current.isEmpty) return;
      final text = current.substring(0, current.length - 1);
      controller!.text = text;
      controller!.selection = TextSelection.fromPosition(
        TextPosition(offset: text.length),
      );
    } else {
      onDelete?.call();
    }
  }

  static const int _cols = 3;
  static const int _rows = 4;

  @override
  Widget build(BuildContext context) {
    final keys = <_KeypadKey>[
      for (var i = 1; i <= 9; i++)
        _KeypadKey(label: "$i", onTap: () => _insert("$i"), colors: colors),
      if (allowMinus)
        _KeypadKey(label: "-", onTap: () => _insert("-"), colors: colors)
      else if (allowComma)
        _KeypadKey(label: ",", onTap: () => _insert(","), colors: colors)
      else
        _KeypadKey(label: "", onTap: () {}, colors: colors, isPlaceholder: true),
      _KeypadKey(label: "0", onTap: () => _insert("0"), colors: colors),
      _KeypadKey(
        icon: Icons.backspace_outlined,
        onTap: _delete,
        colors: colors,
        isDelete: true,
      ),
    ];

    // TapRegion : regroupe ce clavier avec le TextField qui partage le même
    // groupId, pour que taper une touche ne soit jamais interprété comme un
    // tap "en dehors" du champ actif.
    return TapRegion(
      groupId: groupId,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Espace dispo, en retirant les gouttières entre touches.
          final availableWidth = constraints.maxWidth - spacing * (_cols - 1);
          final hasBoundedHeight = constraints.maxHeight.isFinite;
          final availableHeight = hasBoundedHeight
              ? constraints.maxHeight - spacing * (_rows - 1)
              : double.infinity;

          // Touche carrée : on prend le plus petit des deux pour ne jamais
          // déborder, ni en largeur ni en hauteur.
          final widthPerKey = availableWidth / _cols;
          final heightPerKey = hasBoundedHeight ? availableHeight / _rows : widthPerKey;
          final keySize = widthPerKey < heightPerKey ? widthPerKey : heightPerKey;

          final gridWidth = keySize * _cols + spacing * (_cols - 1);
          final gridHeight = keySize * _rows + spacing * (_rows - 1);

          return Center(
            child: SizedBox(
              width: gridWidth,
              height: gridHeight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var r = 0; r < _rows; r++) ...[
                    if (r != 0) SizedBox(height: spacing),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var c = 0; c < _cols; c++) ...[
                          if (c != 0) SizedBox(width: spacing),
                          SizedBox(
                            width: keySize,
                            height: keySize,
                            child: keys[r * _cols + c],
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _KeypadKey extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final RoadlyKeypadColors colors;
  final bool isDelete;
  final bool isPlaceholder;

  const _KeypadKey({
    this.label,
    this.icon,
    required this.onTap,
    required this.colors,
    this.isDelete = false,
    this.isPlaceholder = false,
  });

  @override
  State<_KeypadKey> createState() => _KeypadKeyState();
}

class _KeypadKeyState extends State<_KeypadKey> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.isPlaceholder) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPlaceholder) return const SizedBox.shrink();

    final colors = widget.colors;
    final background = widget.isDelete ? colors.deleteBackground : colors.background;
    final foreground = widget.isDelete ? colors.deleteForeground : colors.foreground;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border, width: 1),
            boxShadow: _pressed
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Center(
            child: widget.icon != null
                ? Icon(widget.icon, color: foreground, size: 24)
                : Text(
                    widget.label!,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}