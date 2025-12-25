import 'package:flutter/material.dart';
import '../models/user_preferences.dart';
import '../models/signal.dart';
import '../services/auth_service.dart';
import '../services/signal_repository.dart';

class AppStateProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final SignalRepository _signalRepository = SignalRepository();

  bool _isAuthenticated = false;
  bool _hasCompletedOnboarding = false;
  UserPreferences? _userPreferences;
  List<Signal> _signals = [];
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  UserPreferences? get userPreferences => _userPreferences;
  List<Signal> get signals => _signals;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    final success = await _authService.login(email, password);
    if (success) {
      _isAuthenticated = true;
      notifyListeners();
    }
    return success;
  }

  Future<bool> signup(String email, String password) async {
    final success = await _authService.signup(email, password);
    if (success) {
      _isAuthenticated = true;
      notifyListeners();
    }
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    _hasCompletedOnboarding = false;
    _userPreferences = null;
    _signals = [];
    notifyListeners();
  }

  void completeOnboarding(List<String> interests, String role) {
    _userPreferences = UserPreferences(interests: interests, role: role);
    _hasCompletedOnboarding = true;
    notifyListeners();
    fetchSignals();
  }

  Future<void> fetchSignals() async {
    _isLoading = true;
    notifyListeners();

    final interests = _userPreferences?.interests ?? [];
    _signals = await _signalRepository.fetchSignals(interests);

    _isLoading = false;
    notifyListeners();
  }
}
