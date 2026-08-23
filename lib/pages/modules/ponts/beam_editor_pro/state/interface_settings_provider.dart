import 'package:flutter/material.dart';

class InterfaceSettingsProvider extends ChangeNotifier {
  bool _afficherValeursCharges = true;
  bool get afficherValeursCharges => _afficherValeursCharges;

  bool _afficherCotations = true;
  bool get afficherCotations => _afficherCotations;

  bool _afficherReactions = true;
  bool get afficherReactions => _afficherReactions;

  void setAfficherValeursCharges(bool value) {
    _afficherValeursCharges = value;
    notifyListeners();
  }

  void setAfficherCotations(bool value) {
    _afficherCotations = value;
    notifyListeners();
  }

  void setAfficherReactions(bool value) {
    _afficherReactions = value;
    notifyListeners();
  }
}