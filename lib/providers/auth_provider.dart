import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      _isAuthenticated = true;
      _currentUser = await _apiService.fetchUserProfile();
    } else {
      _isAuthenticated = false;
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<bool> register(String email, String username, String fullname, String password, int roleId) async {
    try {
      final success = await _apiService.registerUser(email, username, fullname, password, roleId);
      return success;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> signIn(String email, String password) async {
    final success = await _apiService.login(email, password);
    if (success) {
      await checkAuthStatus();
      return true;
    }
    return false;
  }

  Future<void> signOut() async {
    await _apiService.logout();
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }
}