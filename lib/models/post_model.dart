// lib/models/post_model.dart

// Yardımcı fonksiyon: JSON'dan gelen değeri güvenli bir şekilde int? olarak döndürür.
// Null, string (sayısal), veya int olmayan her değeri null yapar.
int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null; 
}

// -----------------------------------------------------------
// Role Model
// -----------------------------------------------------------
class Role {
  final int roleid;
  final String rolename;

  Role({
    required this.roleid,
    required this.rolename,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      roleid: _safeInt(json['roleid']) ?? 0, 
      rolename: json['rolename'] ?? 'Bilinmeyen Rol',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roleid': roleid,
      'rolename': rolename,
    };
  }
}

// -----------------------------------------------------------
// User Model (Biyografi ve tüm sayaçları içerir)
// -----------------------------------------------------------
class User {
  final int? userid; 
  final String email;
  final String username;
  final String fullname;
  
  final String? profileimageurl;
  final String? biography; // Hata çözümü için eklendi
  final Role? role;
  
  final int? score; 
  final DateTime createdat; 
  final int? followersCount;
  final int? followingCount;

  User({
    this.userid, 
    String? email,     
    String? username,  
    String? fullname,  
    this.profileimageurl,
    this.biography,
    this.role,
    this.score, 
    DateTime? createdat,
    this.followersCount, 
    this.followingCount,
  }) : 
       // Zorunlu String alanlara güvenli varsayılan değer atama
       email = email ?? 'bilinmeyen@bilinmeyen.com',
       username = username ?? 'bilinmeyen_kullanici',
       fullname = fullname ?? 'Bilinmeyen Kullanıcı',
       createdat = createdat ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    final roleJson = json['role'];
    
    // Güvenli Sayısal Okuma
    final int? safeUserId = _safeInt(json['id'] ?? json['userid']);
    final int? safeScore = _safeInt(json['score']);
    final int? safeFollowersCount = _safeInt(json['followers_count']);
    final int? safeFollowingCount = _safeInt(json['following_count']);

    // Güvenli Tarih Okuma
    DateTime? parsedDate;
    final dateString = json['created_at'] ?? json['createdat'];
    if (dateString is String) {
      try {
        parsedDate = DateTime.parse(dateString);
      } catch (_) {}
    }

    return User(
      userid: safeUserId, 
      
      // Güvenli String okuma (null gelirse kurucu varsayılan atamayı yapacak)
      email: json['email'] as String?,
      username: json['username'] as String?,
      fullname: json['fullname'] as String?,
      
      profileimageurl: json['profile_picture_url'] ?? json['profileimageurl'],
      biography: json['biography'] as String?, // biography alanı okundu
      role: roleJson != null ? Role.fromJson(roleJson as Map<String, dynamic>) : null,
      
      score: safeScore,
      
      createdat: parsedDate,
      
      followersCount: safeFollowersCount,
      followingCount: safeFollowingCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userid': userid,
      'email': email,
      'username': username,
      'fullname': fullname,
      'profileimageurl': profileimageurl,
      'biography': biography,
      'role': role?.toJson(),
      'score': score,
      'createdat': createdat.toIso8601String(),
      'followers_count': followersCount,
      'following_count': followingCount,
    };
  }
}

// -----------------------------------------------------------
// Comment Model
// -----------------------------------------------------------
class Comment {
  final int commentid; 
  final String commenttext;
  final User user; 
  final DateTime createdat;

  Comment({
    required this.commentid,
    required this.commenttext,
    required this.user,
    required this.createdat,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    return Comment(
      commentid: _safeInt(json['commentid']) ?? 0,
      commenttext: json['commenttext'] ?? '',
      user: User.fromJson(userJson as Map<String, dynamic>), 
      createdat: DateTime.parse(json['createdat']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentid': commentid,
      'commenttext': commenttext,
      'user': user.toJson(),
      'createdat': createdat.toIso8601String(),
    };
  }
}

// -----------------------------------------------------------
// Post Model (title, status, category içerir)
// -----------------------------------------------------------
class Post {
  final int postid; 
  final User user; 
  final String textcontent;
  final String? imageurl;
  final int sharecount; 
  final DateTime createdat;
  final List<Comment> comments;
  final int likesCount; 
  final bool isLikedByUser;

  final String title;    // Hata çözümü için eklendi
  final String status;   // Hata çözümü için eklendi
  final String category; // Hata çözümü için eklendi

  Post({
    required this.postid,
    required this.user,
    required this.textcontent,
    this.imageurl,
    required this.sharecount,
    required this.createdat,
    required this.comments,
    required this.likesCount,
    required this.isLikedByUser,
    this.title = 'Başlıksız', 
    this.status = 'Yayınlandı', 
    this.category = 'Hepsi', 
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    return Post(
      postid: _safeInt(json['postid']) ?? 0,
      user: User.fromJson(userJson as Map<String, dynamic>), 
      textcontent: json['textcontent'] ?? '',
      imageurl: json['imageurl'] as String?,
      sharecount: _safeInt(json['sharecount']) ?? 0,
      createdat: DateTime.parse(json['createdat']),
      comments: (json['comments'] as List? ?? [])
          .map((comment) => Comment.fromJson(comment as Map<String, dynamic>))
          .toList(),
      likesCount: _safeInt(json['likes_count']) ?? 0,
      isLikedByUser: json['is_liked_by_user'] ?? false,
      
      // Hata çözümü için eklendi
      title: json['title'] ?? json['textcontent'] ?? 'Başlıksız Gönderi',
      status: json['status'] ?? 'Yayınlandı',
      category: json['category'] ?? 'Hepsi',
    );
  }

  Post copyWith({
    int? postid,
    User? user,
    String? textcontent,
    String? imageurl,
    int? sharecount,
    DateTime? createdat,
    List<Comment>? comments,
    int? likesCount,
    bool? isLikedByUser,
    String? title,
    String? status,
    String? category,
  }) {
    return Post(
      postid: postid ?? this.postid,
      user: user ?? this.user,
      textcontent: textcontent ?? this.textcontent,
      imageurl: imageurl ?? this.imageurl,
      sharecount: sharecount ?? this.sharecount,
      createdat: createdat ?? this.createdat,
      comments: comments ?? this.comments,
      likesCount: likesCount ?? this.likesCount,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
      title: title ?? this.title,
      status: status ?? this.status,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postid': postid,
      'user': user.toJson(),
      'textcontent': textcontent,
      'imageurl': imageurl,
      'sharecount': sharecount,
      'createdat': createdat.toIso8601String(),
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'likes_count': likesCount,
      'is_liked_by_user': isLikedByUser,
      'title': title,
      'status': status,
      'category': category,
    };
  }
}