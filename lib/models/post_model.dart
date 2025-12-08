// models/post_model.dart
class Post {
 final int postid;
 final User user; // Django'da Post modelinde User Foreign Key'i zorunlu olduğu için non-nullable kalabilir.
 final String textcontent;
 final String? imageurl;
 final int sharecount;
 final DateTime createdat;
 final List<Comment> comments;
 final int likesCount;
 final bool isLikedByUser;

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
});

factory Post.fromJson(Map<String, dynamic> json) {
final userJson = json['user'];
return Post(
postid: json['postid'],
user: User.fromJson(userJson as Map<String, dynamic>), 
textcontent: json['textcontent'],
imageurl: json['imageurl'],
 sharecount: json['sharecount'],
 createdat: DateTime.parse(json['createdat']),
 comments: (json['comments'] as List)
 .map((comment) => Comment.fromJson(comment))
.toList(),
 likesCount: json['likes_count'],
 isLikedByUser: json['is_liked_by_user'],
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
};
}
}
// -----------------------------------------------------------

class User {
final int userid;
final String email;
final String username;
final String fullname;
final String? profileimageurl;
final Role? role; // 👈 Burası nullable yapıldı
final int score;
final DateTime createdat;
final int followersCount;
final int followingCount;

User({
 required this.userid,
 required this.email,
 required this.username,
 required this.fullname,
 this.profileimageurl,
 this.role, // 👈 Constructor güncellendi
required this.score,
 required this.createdat,
 required this.followersCount,
 required this.followingCount,
});

factory User.fromJson(Map<String, dynamic> json) {
    final roleJson = json['role'];
return User(
userid: json['userid'],
 email: json['email'],
username: json['username'],
 fullname: json['fullname'],
 profileimageurl: json['profileimageurl'],
      
      // 🌟 DÜZELTME: Role null ise, null döndür; aksi halde dönüştür.
 role: roleJson != null ? Role.fromJson(roleJson as Map<String, dynamic>) : null, 
      
 score: json['score'],
 createdat: DateTime.parse(json['createdat']),
 followersCount: json['followers_count'],
 followingCount: json['following_count'],
 );
}

Map<String, dynamic> toJson() {
 return {
  'userid': userid,
  'email': email,
  'username': username,
  'fullname': fullname,
  'profileimageurl': profileimageurl,
  'role': role?.toJson(), // 👈 Null kontrolü eklendi
  'score': score,
  'createdat': createdat.toIso8601String(),
  'followers_count': followersCount,
  'following_count': followingCount,
};
}
}
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
 roleid: json['roleid'],
rolename: json['rolename'],
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

class Comment {
final int commentid;
final String commenttext;
final User user; // Django'da zorunlu olduğu için non-nullable kalabilir
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
commentid: json['commentid'],
commenttext: json['commenttext'],

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