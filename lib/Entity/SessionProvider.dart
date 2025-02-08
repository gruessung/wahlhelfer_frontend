import 'package:flutter/material.dart';

import 'SessionData.dart';

class SessionProvider extends ChangeNotifier {
  String _token = "";
  String _password = "";
  SessionData? _sessionData;

  SessionData? get sessionData => _sessionData;
  String get token => _token;
  String get password => _password;

  void setToken(String token) {
    _token = token;
    notifyListeners(); // UI aktualisieren
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners(); // UI aktualisieren
  }



  void setSessionData(SessionData data) {
    _sessionData = data;
    notifyListeners();
  }
}