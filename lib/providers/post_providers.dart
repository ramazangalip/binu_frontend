import 'package:binu_frontend/services/api_service.dart';
import 'package:flutter/material.dart';
import '../models/post_model.dart';

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
      _posts = await _apiService.getPosts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Yeni post ekle
  Future<void> createPost({
    required String textContent,
    String? imageUrl,
  }) async {
    try {
      final newPost = await _apiService.createPost(
        textContent: textContent,
        imageUrl: imageUrl,
      );
      _posts.insert(0, newPost);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Post'u beğen/beğeniyi kaldır
  Future<void> toggleLike(int postId) async {
    try {
      final result = await _apiService.likePost(postId);
      
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