import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/auth_storage.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthService authService,
    required AuthStorage authStorage,
  }) : _authService = authService,
       _authStorage = authStorage;

  static const _tokenKey = 'deepshield_token';
  static const _userIdKey = 'deepshield_user_id';
  static const _emailKey = 'deepshield_email';

  final AuthService _authService;
  final AuthStorage _authStorage;

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _signupSuccessMessage;
  String? _token;
  String? _userId;
  String? _userEmail;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get signupSuccessMessage => _signupSuccessMessage;

  String get userDisplayName {
    final email = _userEmail;
    if (email == null || email.isEmpty) {
      return 'DeepShield User';
    }
    return email.split('@').first;
  }

  Future<void> tryAutoLogin() async {
    final session = await _authStorage.loadSession();
    final token = session[_tokenKey];
    final userId = session[_userIdKey];
    final email = session[_emailKey];

    if (token != null) {
      _token = token;
      _userId = userId;
      _userEmail = email;
      _isLoggedIn = true;
    } else {
      _token = null;
      _userId = null;
      _userEmail = null;
      _isLoggedIn = false;
    }

    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _signupSuccessMessage = null;
    notifyListeners();

    final result = await _authService.login(email, password);

    if (result.success &&
        result.accessToken != null &&
        result.userId != null &&
        result.email != null) {
      _token = result.accessToken;
      _userId = result.userId;
      _userEmail = result.email;
      _isLoggedIn = true;
      await _authStorage.saveSession(_token!, _userId!, _userEmail!);
    } else {
      _errorMessage = result.errorMessage;
      _isLoggedIn = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signup(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _signupSuccessMessage = null;
    notifyListeners();

    final result = await _authService.signup(email, password);

    final message = result.errorMessage;
    if (message != null && message.startsWith('Account created')) {
      _signupSuccessMessage = message;
    } else {
      _errorMessage = message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    final activeToken = _token;
    if (activeToken != null && activeToken.isNotEmpty) {
      await _authService.logout(activeToken);
    }

    await _authStorage.clearSession();
    _isLoggedIn = false;
    _isLoading = false;
    _token = null;
    _userId = null;
    _userEmail = null;
    _signupSuccessMessage = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearSignupSuccessMessage() {
    if (_signupSuccessMessage == null) {
      return;
    }
    _signupSuccessMessage = null;
    notifyListeners();
  }
}
