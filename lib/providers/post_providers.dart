// lib/providers/post_provider.dart

import 'dart:convert'; // jsonDecode için gerekli
import 'package:binu_frontend/services/api_service.dart';
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import 'package:dio/dio.dart'; // DioException ve Response objelerini işlemek için
// import 'dart:io'; // File tipine artık burada gerek yok

class PostProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Postları yükle
  Future<void> fetchPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // API'den doğrudan List<Post> beklenir (http getPosts metodu)
      _posts = await _apiService.getPosts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🎯 GÜNCELLENDİ: Yeni post ekle (File yerine URL kabul eder)
  Future<void> createPost({
    required String text,
    required String category,
    String? imageUrl, // 🌟 KRİTİK DEĞİŞİKLİK: File yerine String URL bekleniyor
  }) async {
    try {
      // createPost artık http.Response döndürdüğü için tipini http.Response'a ayarladık
      final response = await _apiService.createPost(
        text: text,
        category: category,
        imageUrl: imageUrl, // 🌟 imageUrl gönderiliyor
      );
      
      // Yanıtı http.Response'dan alıp JSON'a çeviriyoruz.
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      if (responseData is Map<String, dynamic>) {
        final newPost = Post.fromJson(responseData);
        _posts.insert(0, newPost);
        notifyListeners();
      } else {
        throw Exception('Sunucudan geçersiz post formatı alındı.');
      }
    } catch (e) {
      // DioException yerine genel Exception yakalanıyor, çünkü ApiService artık http.Response döndürüyor
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Post'u beğen/beğeniyi kaldır
  Future<void> toggleLike(int postId) async {
    try {
      await _apiService.likePost(postId);
      
      // Postları yeniden yükle (beğeni durumunu güncellemek için)
      await fetchPosts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Yorum ekle
  Future<void> addComment({
    required int postId,
    required String commentText,
  }) async {
    try {
      await _apiService.addComment(
        postId: postId,
        commentText: commentText,
      );
      
      // Postları yeniden yükle (yeni yorumu görmek için)
      await fetchPosts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Hata mesajını temizle
  void clearError() {
    _error = null;
    notifyListeners();
  }
}