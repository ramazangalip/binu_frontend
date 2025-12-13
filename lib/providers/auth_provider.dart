import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
// import '../models/user_model.dart'; // <-- KALDIRILDI
import '../models/post_model.dart'; // <-- User sınıfı buradan alınır

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // DÜZELTME: UserModel? yerine User? kullanıldı
  User? _currentUser; 
  bool _isAuthenticated = false;
  
  // DÜZELTME: Getter tipi User? olarak değiştirildi
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: 'access_token');
    
    if (token != null) {
      _isAuthenticated = true;
      // Atama başarılı: fetchUserProfile() -> User? döndürür
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
      // Hata yönetimi burada yapılabilir veya fırlatılabilir.
      rethrow;
    }
  }

  Future<bool> signIn(String email, String password) async {
    final success = await _apiService.login(email, password);
    
    if (success) {
      // Başarılı girişten sonra kullanıcı profilini çek ve durumu güncelle
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