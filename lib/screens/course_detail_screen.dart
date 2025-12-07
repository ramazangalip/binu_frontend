import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Django'daki alan adlarıyla eşleşen veri modeli
class CourseDetails {
  final String courseCode;
  final String courseName;
  final String description;
  final String videoUrl;
  final String teacherName;

  CourseDetails({
    required this.courseCode,
    required this.courseName,
    required this.description,
    required this.videoUrl,
    required this.teacherName,
  });
}

class CourseDetailScreen extends StatefulWidget {
  // HomeScreen'den gönderilecek kurs ID'si
  final int courseId; 
  
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  CourseDetails? _courseDetails;
  bool _isLoading = true;
  YoutubePlayerController? _youtubeController;
  
  static const String _baseUrl = 'http://10.0.2.2:8000/api/';

  @override
  void initState() {
    super.initState();
    _fetchCourseDetails();
  }

  Future<void> _fetchCourseDetails() async {
    try {
      // Tekil kurs detayını çekmek için CourseViewSet'in retrieve/detay URL'si
      final response = await http.get(Uri.parse('${_baseUrl}courses/${widget.courseId}/'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        
        // Öğretmen adını güvenli bir şekilde çekme
        final teacherData = jsonResponse['teacher'];
        String teacherName = "Öğretmen Yok";
        if (teacherData != null && teacherData is Map && teacherData.containsKey('fullname')) {
          teacherName = teacherData['fullname'] as String;
        }

        final details = CourseDetails(
          courseCode: jsonResponse['coursecode'] as String,
          courseName: jsonResponse['coursename'] as String,
          description: jsonResponse['description'] as String,
          videoUrl: jsonResponse['video_url'] ?? '', // Video URL'si boş olabilir
          teacherName: teacherName,
        );
        
        // YouTube Kontrolcüsünü başlatma
        if (details.videoUrl.isNotEmpty) {
          final videoId = YoutubePlayer.convertUrlToId(details.videoUrl);
          if (videoId != null) {
            _youtubeController = YoutubePlayerController(
              initialVideoId: videoId,
              flags: const YoutubePlayerFlags(
                autoPlay: false,
                mute: false,
              ),
            );
          }
        }
        
        setState(() {
          _courseDetails = details;
          _isLoading = false;
        });
      } else {
        print('Ders detayları yüklenirken hata oluştu: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ders detayları yüklenemedi.')),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Ağ hatası: $e');
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sunucuya bağlanılamadı.')),
          );
        }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Yükleniyor...')),
        body: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
      );
    }
    
    if (_courseDetails == null) {
        return Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: const Center(child: Text("Ders bilgisi bulunamadı.")),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, 
      appBar: AppBar(
        title: Text('${_courseDetails!.courseCode} Detay'),
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Oynatıcı
            if (_youtubeController != null)
              YoutubePlayer(
                controller: _youtubeController!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: colorScheme.primary,
                progressColors: ProgressBarColors(
                  playedColor: colorScheme.primary,
                  handleColor: colorScheme.primaryContainer,
                ),
                onReady: () {
                  // İsteğe bağlı: Video hazır olduğunda ne yapılacağı
                },
              )
            else
              // Video URL'si yoksa veya hatalıysa gösterilecek yer tutucu
              Container(
                height: 200,
                color: colorScheme.surfaceVariant,
                child: Center(
                  child: Text(
                    'Video içeriği yüklenemedi veya yok.', 
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),

            // Ders Adı ve Açıklaması
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kurs Kodu ve Eğitmen
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _courseDetails!.courseCode,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        'Eğitmen: ${_courseDetails!.teacherName}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Kurs Adı
                  Text(
                    _courseDetails!.courseName,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontSize: 24,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Kurs Açıklaması
                  Text(
                    _courseDetails!.description.isEmpty ? "Bu ders için henüz bir açıklama girilmemiştir." : _courseDetails!.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      height: 1.6,
                      color: colorScheme.onSurface, 
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}