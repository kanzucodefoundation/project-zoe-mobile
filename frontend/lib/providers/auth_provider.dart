import 'package:flutter/material.dart';
import '../entities/user.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, failed }

class AuthProvider extends ChangeNotifier {
  AuthProvider();

  AuthStatus _status = AuthStatus.unauthenticated;
  AuthStatus get status => _status;

  UserEntity? _user;
  UserEntity? get user => _user;

  String? _error;
  String? get error => _error;

  Future<void> login(String email, String password) async {
    _status = AuthStatus.authenticating;
    _error = null;
    notifyListeners();

    try {
      // Mock delay to simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock user creation
      _user = UserEntity(id: '1', name: 'User Name', email: email);
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.failed;
      _error = e.toString();
    }

    notifyListeners();
  }

  void logout() {
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
