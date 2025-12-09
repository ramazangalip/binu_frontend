// course_model.dart (veya modellerinizin bulunduğu dosya)

// Gerekli importlar (User ve Role modelinizin tanımlı olduğunu varsayıyoruz)
// import 'user_model.dart'; // User modelinizin dosya yoluna göre düzenleyin

import 'package:binu_frontend/models/post_model.dart';

class Course {
  final int courseid;
  final String courseCode;
  final String courseName;
  final String? category;
  final String? description; // Django modelinizdeki alan
  final String? videoUrl;    // Django modelinizdeki alan
  final User? teacher;       // Teacher null olabilir

  Course({
    required this.courseid,
    required this.courseCode,
    required this.courseName,
    this.category,
    this.description,
    this.videoUrl,
    this.teacher,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    final teacherJson = json['teacher'];
    
    // Açıklamaların null gelme ihtimaline karşı kontrol
    String? parsedDescription = json['description'];
    if (parsedDescription != null && parsedDescription.toLowerCase() == 'null') {
      parsedDescription = null;
    }

    return Course(
      courseid: json['courseid'],
      courseCode: json['coursecode'],
      courseName: json['coursename'],
      category: json['category'],
      description: parsedDescription,
      videoUrl: json['video_url'],
      
      // Öğretmen bilgisi (teacher) null ise, null döner; aksi halde User'a dönüştürülür.
      teacher: teacherJson != null 
          ? User.fromJson(teacherJson as Map<String, dynamic>) 
          : null,
    );
  }

  // Eğer bu modelde de copyWith kullanmak isterseniz:
  Course copyWith({
    int? courseid,
    String? courseCode,
    String? courseName,
    String? category,
    String? description,
    String? videoUrl,
    User? teacher,
  }) {
    return Course(
      courseid: courseid ?? this.courseid,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      category: category ?? this.category,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      teacher: teacher ?? this.teacher,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseid': courseid,
      'coursecode': courseCode,
      'coursename': courseName,
      'category': category,
      'description': description,
      'video_url': videoUrl,
      'teacher': teacher?.toJson(),
    };
  }
}

// 🚨 NOT: Eğer User modeliniz bu dosyanın dışında ise, buraya import etmeyi unutmayın.
// Eğer User modeliniz de yoksa, yukarıdaki post_model.dart dosyasından User modelini buraya dahil edin.