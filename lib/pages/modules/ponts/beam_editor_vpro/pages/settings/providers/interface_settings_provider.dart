import 'package:flutter/material.dart';

class InterfaceSettingsProvider extends ChangeNotifier {
  bool _afficherValeursCharges = true;
  bool get afficherValeursCharges => _afficherValeursCharges;

  void setAfficherValeursCharges(bool value) {
    _afficherValeursCharges = value;
    notifyListeners();
  }
}