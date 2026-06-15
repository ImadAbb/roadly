import 'package:flutter/foundation.dart';

// Global ValueNotifier used across the editor to broadcast the currently selected element.
final ValueNotifier<dynamic> selectedElementNotifier = ValueNotifier<dynamic>(null);
