import 'dart:convert';
import 'dart:io';
import 'package:binu_frontend/models/course_model.dart';
import 'package:binu_frontend/models/post_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  

  static String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://127.0.0.1:8000/api'; // iOS
  }

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
      ).timeout(const Duration(seconds: 10));
      
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
      ).timeout(const Duration(seconds: 10));

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
  
  // DUZELTILMIS fetchLeaderboard metodu (Sinifin icine tasindi)
  Future<List<User>> fetchLeaderboard() async {
  try {
    // LeaderboardView zaten herkesin erissimine acik oldugu icin token zorunlu degil.
    final response = await http.get(
      Uri.parse('$_baseUrl/leaderboard/'), // Django LeaderboardView URL'i
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

  Future<UserModel?> fetchUserProfile() async {
    final url = Uri.parse('$_baseUrl/users/me/');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      print("Profil cekme hatasi: $e");
      return null;
    }
  }
  
  // Profil Bilgilerini Guncelleme (PATCH)
  Future<UserModel> updateProfile({
    String? fullName,
    String? username,
    String? biography,
    String? profileImageUrl,
  }) async {
    final url = Uri.parse('$_baseUrl/users/update/'); // Django'daki PATCH endpoint'i
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
          if (biography != null) 'biography': biography, // Yeni biography alani
          if (profileImageUrl != null) 'profileimageurl': profileImageUrl,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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
      ).timeout(const Duration(seconds: 10));

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

  // Yeni post olustur
  Future<Post> createPost({
    required String textContent,
    String? imageUrl,
  }) async {
    try {
      final token = await _getToken();
      
      if (token == null) {
        throw Exception('Giris yapmaniz gerekiyor');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/posts/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'textcontent': textContent,
          if (imageUrl != null) 'imageurl': imageUrl,
        }),
      );

      if (response.statusCode == 201) {
        return Post.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Post olusturulamadi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Post olusturulurken hata olustu: $e');
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
}