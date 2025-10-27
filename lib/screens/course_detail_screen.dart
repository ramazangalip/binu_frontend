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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ders Detayı'),
        backgroundColor: Colors.white,
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
                            color: Colors.white.withOpacity(0.7),
                            size: 60,
                          ),
                        ),
                        VideoProgressIndicator(_controller, allowScrubbing: true),
                      ],
                    ),
                  )
                : Container(
                    height: 200,
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),

            // Ders Adı ve Açıklaması
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Python ile Veri Yapıları ve Algoritmalar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bu derste, programlamanın temel taşlarından olan veri yapıları ve algoritmalar konusunu Python programlama dili üzerinden A\'dan Z\'ye ele alacağız.\n\nListeler, sözlükler, demetler gibi temel veri yapılarından başlayarak, stack, queue, linked list gibi daha ileri seviye konulara geçiş yapacağız. Ayrıca, sıralama (sorting) ve arama (searching) algoritmalarını derinlemesine inceleyerek, kodunuzun verimliliğini nasıl artırabileceğinizi öğreneceksiniz.\n\nBu kurs, yazılım mülakatlarına hazırlanan öğrenciler ve algoritmik düşünme yeteneğini geliştirmek isteyen herkes için uygundur.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
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