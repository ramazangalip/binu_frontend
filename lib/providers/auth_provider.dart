import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
// import '../models/user_model.dart'; // Bu import satırını User modeline çevirdik
import '../models/post_model.dart'; // Post modelinin içinde User, Comment, Role modelleri tanımlıydı

// Eğer '../models/user_model.dart' dosyanızda User sınıfınız varsa, import'u buna göre ayarlayın.
// Genel kod tutarlılığı için User (PostModel içinden) kullanıldı.

// NOT: Eğer projenizde User sınıfı ayrı bir dosyada (user_model.dart) ise, 
// o dosyayı import etmelisiniz. Varsayımsal olarak, User modelinin PostModel'de 
// tanımlı olduğu ve doğru import'un 'package:binu_frontend/models/post_model.dart' olduğu varsayılmıştır.

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // UserModel yerine User tipini kullanıyoruz
  User? _currentUser;
  bool _isAuthenticated = false;
  
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      _isAuthenticated = true;
      // fetchUserProfile artık User döndürüyor olmalı
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
  Future<void> updateUserData() async {
  try {
    // API'den en güncel profil bilgilerini (puan dahil) çek
    final updatedUser = await ApiService().fetchUserProfile();
    _currentUser = updatedUser;
    notifyListeners(); // Tüm sayfaları puanın değiştiğine dair haberdar et
  } catch (e) {
    print("Kullanıcı verisi güncellenemedi: $e");
  }
}
}