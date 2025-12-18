import 'dart:convert';
import 'dart:io';
// Dio kütüphanesi import edildi (DioException'ı yakalamak için)
import 'package:binu_frontend/models/notification_model.dart';

import 'package:dio/dio.dart';
import 'package:binu_frontend/models/course_model.dart';
import 'package:binu_frontend/models/post_model.dart'; // User, Post, Comment içerir
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  
  // Base URL tanımı
  static String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://127.0.0.1:8000/api'; // iOS
  }
  
  // Dio instance'ı, sadece multipart/form-data için kullanılıyor
  final Dio _dioInstance = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
    ),
  );

  final _storage = const FlutterSecureStorage();


  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }


  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }


  Future<bool> registerUser(String email, String username, String fullname, String password, int roleId) async {
    final url = Uri.parse('$_baseUrl/register/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'fullname': fullname,
          'password': password,
          'role': roleId,
        }),
      ).timeout(const Duration(seconds: 90));
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        
        throw Exception(errorData.toString());
      }
    } on SocketException {
      throw Exception('Sunucuya baglaniladi. Internet baglantinizi veya sunucu adresini kontrol edin.');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'access_token', value: data['access']);
        await _storage.write(key: 'refresh_token', value: data['refresh']);
        return true;
      }
      
      return false;
    } on SocketException {
      throw Exception('Sunucuya baglaniladi. Internet baglantinizi kontrol edin.');
    } catch (e) {
      rethrow;
    }
  }


  Future<List<Course>> getCourses() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/courses/'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData.map((json) => Course.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        
        throw Exception('Backend izni hatasi: Kurs listesi herkese acik degil.');
      } else {
        throw Exception('Kurslar yuklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kurslar yuklenirken hata olustu: $e');
    }
  }
  
  // Leaderboard metodu (User modeli kullanılır)
  Future<List<User>> fetchLeaderboard() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/leaderboard/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Liderlik tablosu yuklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Liderlik tablosu yuklenirken hata olustu: $e');
    }
  }


  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  // fetchUserProfile metodu (User döndürür)
  Future<User?> fetchUserProfile() async {
    final url = Uri.parse('$_baseUrl/users/me/');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
        if (decodedBody is Map<String, dynamic>) {
          return User.fromJson(decodedBody);
        }
        return null;
      }
      return null;
    } catch (e) {
      print("Profil cekme hatasi: $e");
      return null;
    }
  }
  
  // fetchUserPosts metodu (List<Post> döndürür)
  Future<List<Post>> fetchUserPosts() async {
    final url = Uri.parse('$_baseUrl/posts/my-posts/');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData.map((json) => Post.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Yetkisiz erişim. Lütfen tekrar giriş yapın.');
      } else {
        throw Exception('Gönderiler yüklenemedi: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Sunucuya bağlanılamadı.');
    } catch (e) {
      print("Gönderi çekme hatası: $e");
      rethrow;
    }
  }

  // Profil Bilgilerini Guncelleme (PATCH)
  Future<User> updateProfile({
    String? fullName,
    String? username,
    String? biography,
    String? profileImageUrl,
  }) async {
    final url = Uri.parse('$_baseUrl/users/update/');
    final token = await _getToken();
    
    if (token == null) {
      throw Exception('Giris yapmaniz gerekiyor');
    }

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (fullName != null) 'fullname': fullName,
          if (username != null) 'username': username,
          if (biography != null) 'biography': biography,
          if (profileImageUrl != null) 'profileimageurl': profileImageUrl,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
        
        if (decodedBody is Map<String, dynamic>) {
          return User.fromJson(decodedBody);
        } else {
          throw const FormatException('Sunucudan beklenen kullanıcı verisi formatı (Map) alınamadı.');
        }

      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception('Profil guncellenemedi: ${errorData.toString()}');
      }
    } on SocketException {
      throw Exception('Ag hatasi veya sunucu baglantisi basarisiz.');
    } catch (e) {
      throw Exception('Profil guncellenirken hata olustu: $e');
    }
  }
  
  Future<void> sendPasswordResetRequest(String email) async {
    final url = Uri.parse('$_baseUrl/users/reset-password-request/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Bu e-posta adresi sistemde kayitli degil.');
      } else {
        throw Exception('Sifre sifirlama linki gonderilemedi (Kod: ${response.statusCode}).');
      }
    } on SocketException {
      throw Exception('Sunucuya baglaniladi.');
    }
  }
  
  Future<void> confirmPasswordReset(String uid, String token, String newPassword) async {
    final url = Uri.parse('$_baseUrl/users/reset-password-confirm/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'uid': uid,
        'token': token,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Sifre sifirlama basarisiz oldu.');
    }
  }
  
  // 🎯 GÜNCELLENMİŞ: Dosya Yükleme Metodu (http yerine Dio ile daha tutarlı)
  Future<String?> uploadImage(File? imageFile) async {
    if (imageFile == null) return null;
    
    final token = await _getToken();
    if (token == null) {
      throw Exception('Giriş yapmanız gerekiyor.');
    }
    
    // Dio instance'ına Authorization header'ı ekle
    _dioInstance.options.headers['Authorization'] = 'Bearer $token';

    try {
      FormData formData = FormData.fromMap({
        // ImageViewSet'in beklediği alan adı: 'image' olarak varsayılıyor
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });
      
      // POST /api/images/upload/ endpoint'ine Dio ile gönder
      final response = await _dioInstance.post('/images/upload/', data: formData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // ImageViewSet'ten dönen URL'yi al
        final dynamic newImageUrl = response.data['url'] ?? response.data['image_url'];
        if (newImageUrl is String && newImageUrl.isNotEmpty) {
          return newImageUrl;
        }
      }
      throw Exception('Resim yükleme başarılı ancak sunucudan geçerli URL alınamadı. Kod: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Resim yükleme hatası: ${e.response?.data.toString() ?? e.message}');
    } catch (e) {
      throw Exception('Resim yükleme sırasında hata oluştu: $e');
    }
  }
  
  Future<void> toggleLike(int postId) async {}

  Future<List<Post>> getPosts() async {
    try {
      final token = await _getToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/posts/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Postlar yuklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Postlar yuklenirken hata olustu: $e');
    }
  }

  Future<Post> getPost(int postId) async {
    try {
      final token = await _getToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/posts/$postId/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return Post.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Post yuklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Post yuklenirken hata olustu: $e');
    }
  }


  // 🎯 GÜNCELLENMİŞ: createPost (Artık sadece URL kabul ediyor)
  Future<http.Response> createPost({
    required String text,
    required String category,
    String? imageUrl, // Dosya yerine URL alıyor
  }) async {
    final token = await _getToken();
    
    if (token == null) {
      throw Exception('Giris yapmaniz gerekiyor');
    }

    final httpHeaders = await _getHeaders(); // JSON Header
    httpHeaders['Authorization'] = 'Bearer $token';

    final response = await http.post(
      Uri.parse('$_baseUrl/posts/'), // POST /api/posts/
      headers: httpHeaders,
      body: jsonEncode({
        // Django modelinin beklediği alan adları
        'textcontent': text,
        'category': category,
        
        // Dosya URL'si gönderiliyor
        if (imageUrl != null) 'imageurl': imageUrl,
      }),
    );
    
    // Dio Response değil, http.Response döndürdük
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      final errorData = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(errorData.toString());
    }
  }


  // Post'u begen/begeniyi kaldir
  Future<Map<String, dynamic>> likePost(int postId) async {
    try {
      final token = await _getToken();
      
      if (token == null) {
        throw Exception('Giris yapmaniz gerekiyor');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/posts/$postId/like/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Begeni islemi basarisiz: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Begeni isleminde hata olustu: $e');
    }
  }

  // Post'a yorum ekle
  Future<Comment> addComment({
    required int postId,
    required String commentText,
  }) async {
    try {
      final token = await _getToken();
      
      if (token == null) {
        throw Exception('Giris yapmaniz gerekiyor');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/posts/$postId/comments/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'commenttext': commentText,
        }),
      );

      if (response.statusCode == 201) {
        return Comment.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Yorum eklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Yorum eklenirken hata olustu: $e');
    }
  }

  // Yeni metot: Bildirimleri Çekme
  Future<List<AppNotification>> getNotifications() async {
    final url = Uri.parse('$_baseUrl/notifications/');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
        
        // 🚀 KRİTİK HATA AYIKLAMA KISMI
        print('--- BİLDİRİM VERİSİ BAŞLANGIÇ ---');
        print('Gelen Bildirim sayısı: ${jsonData.length}');
        if (jsonData.isNotEmpty) {
          // İlk objenin yapısını görmek için
          print('İlk Bildirim Yapısı (JSON): ${jsonData.first}');
        }
        print('--- BİLDİRİM VERİSİ SON ---');
        // 🚀 KRİTİK HATA AYIKLAMA KISMI BİTİŞ

        // AppNotification modelini kullanıyoruz
        return jsonData.map((json) => AppNotification.fromJson(json)).toList();
      } else {
        throw Exception('Bildirimler yüklenemedi: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Sunucuya bağlanılamadı.');
    } catch (e) {
      rethrow;
    }
  }

  // Kullanıcıları aramak için yeni metot
Future<List<User>> searchUsers(String query) async {
  if (query.isEmpty) return [];
  // Varsayım: Backend'inizde arama için bir endpoint (örneğin /api/users/search/?q=...) mevcut.
  final response = await http.get(
    Uri.parse('$_baseUrl/users/search/?q=$query'), // Lütfen backend endpoint'ini doğrulayın
    headers: await _getHeaders(),
  );

  if (response.statusCode == 200) {
    final List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
    return jsonResponse.map((userJson) => User.fromJson(userJson)).toList();
  } else {
    throw Exception('Kullanıcı arama başarısız: ${response.statusCode}');
  }
}

// Takip etme/takibi bırakma metodu
Future<Map<String, dynamic>> toggleFollow(int userId) async {
  // Varsayım: Backend'inizde takip etme/bırakma için bir endpoint (örneğin /api/users/{id}/follow/) mevcut.
  final response = await http.post(
    Uri.parse('$_baseUrl/users/$userId/toggle-follow/'), // Lütfen backend endpoint'ini doğrulayın
    headers: await _getHeaders(),
  );

  if (response.statusCode == 200) {
    return json.decode(utf8.decode(response.bodyBytes));
  } else {
    // Hata detayını yakalamaya çalışın
    final errorBody = json.decode(utf8.decode(response.bodyBytes));
    throw Exception(errorBody['detail'] ?? 'Takip işlemi başarısız.');
  }
}

Future<List<Map<String, dynamic>>> fetchConversations() async {
  final url = Uri.parse('$_baseUrl/messages/conversations/');
  
  try {
    final response = await http.get(
      url,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      
      // JSON'u Map listesine dönüştürür (Konuşma Listesi)
      return jsonResponse.map((data) => data as Map<String, dynamic>).toList();
    } else if (response.statusCode == 401) {
      throw Exception("Yetkilendirme başarısız.");
    } else {
      throw Exception("Konuşma listesi yüklenemedi: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception('Ağ hatası veya sunucu hatası: ${e.toString()}');
  }
}
Future<List<dynamic>> getChatHistory(int otherUserId) async {
  final response = await http.get(
    Uri.parse('$_baseUrl/messages/$otherUserId/history/'),
    headers: await _getHeaders(),
  );

  if (response.statusCode == 200) {
    return json.decode(utf8.decode(response.bodyBytes));
  } else {
    throw Exception('Geçmiş mesajlar yüklenemedi');
  }
}
Future<User?> fetchUserById(int userId) async {
  final url = Uri.parse('$_baseUrl/users/$userId/'); 
  try {
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    return null;
  } catch (e) {
    print("Kullanıcı profil çekme hatası: $e");
    return null;
  }
}

// Belirli bir kullanıcının postlarını çekmek için
Future<List<Post>> fetchUserPostsById(int userId) async {
  final url = Uri.parse('$_baseUrl/posts/user/$userId/');
  try {
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
      return jsonData.map((json) => Post.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    return [];
  }
}

// Belirli bir kullanıcının postlarını çekmek için
Future<List<Post>> fetchPostsByUserId(int userId) async {
  final url = Uri.parse('$_baseUrl/posts/user/$userId/'); // Backend post endpoint'inize göre güncelleyin
  try {
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers)
        .timeout(const Duration(seconds: 90));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
      return jsonData.map((json) => Post.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    print("Kullanıcı postlarını çekme hatası: $e");
    return [];
  }
}
}