class UserModel {
  final int userId;
  final String email;
  final String username;
  final String fullName;
  final int roleId;
  final int score;
  final String? profileImageUrl;

  UserModel({
    required this.userId,
    required this.email,
    required this.username,
    required this.fullName,
    required this.roleId,
    required this.score,
    this.profileImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userid'],
      email: json['email'],
      username: json['username'],
      fullName: json['fullname'],
      roleId: json['role']['roleid'],
      score: json['score'],
      profileImageUrl: json['profileimageurl'],
    );
  }
}