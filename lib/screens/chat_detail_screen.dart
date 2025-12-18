import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class ChatDetailScreen extends StatefulWidget {
  final String userName;
  final String avatarUrl;
  final int userId; // Karşı tarafın ID'si

  const ChatDetailScreen({
    Key? key,
    required this.userName,
    required this.avatarUrl,
    required this.userId,
  }) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  WebSocketChannel? _channel;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  late int _myId;

@override
void initState() {
  super.initState();
  
  // 1. AuthProvider'dan güncel kullanıcıyı alıyoruz
  final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
  
  // 2. Güvenlik Kontrolü: Kullanıcı varsa ve ID'si null değilse başlat
  if (user != null && user.userid != null) {
    final int activeMyId = user.userid!;
    
    setState(() {
      _myId = activeMyId;
    });

    print("DEBUG: Sohbet başlatılıyor. Kendi ID: $activeMyId, Karşı ID: ${widget.userId}");

    _fetchHistory();
    _connectWebSocket(activeMyId); // 🚀 ID'yi doğrudan parametre olarak gönderiyoruz
  } else {
    print("HATA: AuthProvider'da kullanıcı ID'si bulunamadı!");
  }
}

  // 1. Adım: Geçmiş Mesajları Çekme (REST API)
  Future<void> _fetchHistory() async {
    try {
      final history = await _apiService.getChatHistory(widget.userId);
      setState(() {
        _messages = history.map((msg) => {
          'text': msg['messagecontent'],
          'isMe': msg['sender']['userid'] == _myId,
          'time': DateTime.parse(msg['sentat']),
        }).toList();
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint("Geçmiş çekilemedi: $e");
      setState(() => _isLoading = false);
    }
  }

  // 2. Adım: WebSocket Bağlantısı
  void _connectWebSocket(int currentUserId) {
  final int otherId = widget.userId;
  // Oda adı: KüçükID_BüyükID
  final String roomId = currentUserId < otherId 
      ? '${currentUserId}_$otherId' 
      : '${otherId}_$currentUserId';
  
  final String wsUrl = 'ws://10.0.2.2:8000/ws/chat/$roomId/';
  
  print("DEBUG: WebSocket Bağlantı URL: $wsUrl");

  try {
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _channel!.stream.listen(
      (data) {
        final decoded = jsonDecode(data);
        final msg = decoded['message'];

        if (mounted && msg != null) {
          setState(() {
            _messages.add({
              'text': msg['text'] ?? '',
              // Karşılaştırmayı parametre olarak gelen currentUserId ile yapıyoruz
              'isMe': msg['sender_id'].toString() == currentUserId.toString(),
              'time': msg['created_at'] != null 
                  ? DateTime.parse(msg['created_at']) 
                  : DateTime.now(),
            });
          });
          _scrollToBottom();
        }
      },
      onError: (error) => print("DEBUG: WebSocket Hatası: $error"),
      onDone: () => print("DEBUG: WebSocket Bağlantısı Kapandı."),
    );
  } catch (e) {
    print("DEBUG: WebSocket Bağlantı Hatası: $e");
  }
}

  // 3. Adım: Mesaj Gönderme (WebSocket üzerinden)
  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final messageData = {
      'message': _controller.text.trim(),
      'sender_id': _myId,
      'receiver_id': widget.userId,
    };

    _channel?.sink.add(jsonEncode(messageData));
    _controller.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 1,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.avatarUrl),
              backgroundColor: colorScheme.surfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(widget.userName, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
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

  // Kabarcık ve Composer widget'ları aynı kalabilir (Önceki mesajınızdaki tasarım çok iyi)
  Widget _buildMessageBubble(String text, bool isMe, DateTime time, ColorScheme colorScheme) {
    final Color bubbleColor = isMe ? colorScheme.primary : colorScheme.surfaceVariant;
    final Color textColor = isMe ? colorScheme.onPrimary : colorScheme.onSurface;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
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
            Text(text, style: TextStyle(color: textColor, fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(time),
              style: TextStyle(fontSize: 10, color: isMe ? textColor.withOpacity(0.7) : colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageComposer(ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                decoration: InputDecoration(
                  hintText: 'Mesaj yaz...',
                  fillColor: colorScheme.surfaceVariant,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: colorScheme.primary),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}