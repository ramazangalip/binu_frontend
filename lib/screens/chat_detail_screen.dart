import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatDetailScreen extends StatefulWidget {
  final String userName;
  final String avatarUrl;

  const ChatDetailScreen({
    Key? key,
    required this.userName,
    required this.avatarUrl,
  }) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Selam! Proje hakkında konuşabilir miyiz?',
      'isMe': false,
      'time': DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      'text': 'Tabii ki, dinliyorum.',
      'isMe': true,
      'time': DateTime.now().subtract(const Duration(minutes: 2)),
    },
    {
      'text': 'Raporun son teslim tarihi ne zamandı?',
      'isMe': false,
      'time': DateTime.now().subtract(const Duration(minutes: 1)),
    },
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'text': _controller.text.trim(),
        'isMe': true,
        'time': DateTime.now(),
      });
      _controller.clear();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      // Arka planı temadan al
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // AppBar rengi temadan (AppTheme'daki appBarTheme) otomatik alınacak,
        // bu yüzden elle backgroundColor ataması kaldırıldı.
        // elevation: 0.5 temayla çakışmaması için kaldırılabilir veya bırakılabilir
        elevation: 1, 
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.avatarUrl),
              backgroundColor: colorScheme.surfaceVariant, // Avatar placeholder rengi
            ),
            const SizedBox(width: 12),
            Text(
              widget.userName,
              // Metin stilini temadan al
              style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18),
            ),
          ],
        ),
        actions: [
          // İkon rengi temadan (AppTheme'daki foregroundColor) otomatik alınır
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.more_vert),
            color: colorScheme.onPrimaryContainer,
          ), 
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg['text'], msg['isMe'], msg['time'], colorScheme);
              },
            ),
          ),
          _buildMessageComposer(colorScheme, theme),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, DateTime time, ColorScheme colorScheme) {
    // Mesaj balonunun arka plan renkleri
    final Color bubbleColor = isMe 
      ? colorScheme.primary // Benim mesajım: Tema ana rengi
      : colorScheme.surfaceVariant; // Karşı tarafın mesajı: Tema yüzey varyant rengi
      
    // Mesaj balonunun içindeki metin renkleri
    final Color textColor = isMe 
      ? colorScheme.onPrimary // Ana renk üzerinde kontrast renk (genellikle beyaz)
      : colorScheme.onSurface; // Yüzey rengi üzerinde kontrast renk (genellikle siyah/koyu gri)

    // Zaman metni rengi
    final Color timeColor = isMe 
      ? colorScheme.onPrimary.withOpacity(0.7) 
      : colorScheme.onSurfaceVariant;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: textColor, // Dinamik metin rengi
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              DateFormat('HH:mm').format(time),
              style: TextStyle(
                fontSize: 11,
                color: timeColor, // Dinamik zaman rengi
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageComposer(ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      // Düzeltme: Arka plan rengi (colorScheme.surface) BoxDecoration içine taşındı.
      decoration: BoxDecoration(
        color: colorScheme.surface, 
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                // Yazı rengi temadan otomatik gelecek
                decoration: InputDecoration(
                  hintText: 'Mesaj yaz...',
                  // Yazı alanı arka planı temadan al (surfaceVariant)
                  fillColor: colorScheme.surfaceVariant, 
                  // hintText rengi temadan al
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant), 
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              // İkon rengini temadan al (ana renk)
              icon: Icon(Icons.send, color: colorScheme.primary), 
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}