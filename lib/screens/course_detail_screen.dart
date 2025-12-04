import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/ders_videosu.mp4')
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      // Arka planı temadan al
      backgroundColor: theme.scaffoldBackgroundColor, 
      appBar: AppBar(
        title: const Text('Ders Detayı'),
        // Arka plan rengi ve metin rengi AppTheme'dan otomatik alınır
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        VideoPlayer(_controller),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                            });
                          },
                          child: Icon(
                            _controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            // Oynat/Durdur ikonu rengi
                            color: Colors.white.withOpacity(0.7),
                            size: 60,
                          ),
                        ),
                        // Video ilerleme çubuğunun rengi temadan alınacak
                        VideoProgressIndicator(
                          _controller, 
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                            // Yüklü tampon rengi temadan (onSurfaceVariant) alınır
                            bufferedColor: colorScheme.onSurfaceVariant.withOpacity(0.4), 
                            // Oynatma rengi temadan (primary) alınır
                            playedColor: colorScheme.primary, 
                            // Arka plan rengi temadan (surfaceVariant) alınır
                            backgroundColor: colorScheme.surfaceVariant, 
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    height: 200,
                    // Video yüklenirken arka plan rengi
                    color: colorScheme.surfaceVariant, 
                    child: Center(
                      child: CircularProgressIndicator(
                        // Yüklenme göstergesi rengi temadan alınır
                        color: colorScheme.primary,
                      ),
                    ),
                  ),

            // Ders Adı ve Açıklaması
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Python ile Veri Yapıları ve Algoritmalar',
                    // Başlık stilini temadan al
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bu derste, programlamanın temel taşlarından olan veri yapıları ve algoritmalar konusunu Python programlama dili üzerinden A\'dan Z\'ye ele alacağız.\n\nListeler, sözlükler, demetler gibi temel veri yapılarından başlayarak, stack, queue, linked list gibi daha ileri seviye konulara geçiş yapacağız. Ayrıca, sıralama (sorting) ve arama (searching) algoritmalarını derinlemesine inceleyerek, kodunuzun verimliliğini nasıl artırabileceğinizi öğreneceksiniz.\n\nBu kurs, yazılım mülakatlarına hazırlanan öğrenciler ve algoritmik düşünme yeteneğini geliştirmek isteyen herkes için uygundur.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      height: 1.6,
                      // Metin rengini temadan al
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