import 'package:binu_frontend/screens/chat_detail_screen.dart'; 
import 'package:flutter/material.dart';

// 💡 Dinamik veri çekimi için gerekli importlar
import 'package:binu_frontend/services/api_service.dart';
import 'package:binu_frontend/models/post_model.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ApiService _apiService = ApiService();
  
  List<Map<String, dynamic>> _conversations = []; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final List<Map<String, dynamic>> fetchedData = await _apiService.fetchConversations();
      
      if (mounted) {
        setState(() {
          _conversations = fetchedData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konuşmalar yüklenemedi: ${e.toString()}')),
        );
      }
    }
  }

  void _openNewChatModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (BuildContext context, ScrollController scrollController) {
            return _NewChatModalContent(
              scrollController: scrollController,
              apiService: _apiService, 
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, 
      appBar: AppBar(
        title: const Text('Mesajlar'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _openNewChatModal(context), 
            icon: const Icon(Icons.add_comment_outlined),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : RefreshIndicator( 
              onRefresh: _fetchConversations,
              child: _conversations.isEmpty
                  ? Center(child: Text('Henüz hiç sohbetin yok.', style: TextStyle(color: colorScheme.onSurfaceVariant)))
                  : ListView.separated(
                      itemCount: _conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = _conversations[index];
                        
                        // Backend'den gelen 'other_user' yapısını ayrıştırıyoruz
                        final otherUser = conversation['other_user'] as Map<String, dynamic>?;
                        final unreadCount = conversation['unreadCount'] as int? ?? 0;
                        
                        final String name = otherUser?['fullname'] as String? ?? 'Bilinmeyen Kullanıcı';
                        final String lastMessage = conversation['messagecontent'] as String? ?? 'Mesaj yok.';
                        final String avatarUrl = otherUser?['profileimageurl'] as String? ?? '';
                        
                        final String time = conversation['sentat'] != null 
                            ? _formatTimeAgo(DateTime.parse(conversation['sentat'])) 
                            : '';

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                            backgroundColor: colorScheme.surfaceVariant, 
                            child: avatarUrl.isEmpty ? Icon(Icons.person, color: colorScheme.onSurface) : null,
                          ),
                          title: Text(name, style: theme.textTheme.titleMedium),
                          subtitle: Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7), 
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(time, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                              if (unreadCount > 0) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary, 
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    unreadCount.toString(),
                                    style: TextStyle(color: colorScheme.onPrimary, fontSize: 12), 
                                  ),
                                )
                              ]
                            ],
                          ),
                          onTap: () {
                            // 🚀 DÜZELTME VE DEBUG: Hem 'userid' hem 'id' alanını kontrol ediyoruz
                            final int targetId = otherUser?['userid'] ?? otherUser?['id'] ?? 0;
                            
                            debugPrint("DEBUG: Tıklanan Sohbet - Hedef ID: $targetId");
                            debugPrint("DEBUG: Diğer Kullanıcı Verisi: $otherUser");

                            if (targetId != 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatDetailScreen(
                                    userName: name,
                                    avatarUrl: avatarUrl,
                                    userId: targetId,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Hata: Kullanıcı bilgisi alınamadı.')),
                              );
                            }
                          },
                        );
                      },
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 1,
                        color: colorScheme.outlineVariant, 
                        indent: 80,
                      ),
                    ),
            ),
    );
  }
  
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${difference.inDays ~/ 7}h';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}g';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}s';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}dk';
    } else {
      return 'şimdi';
    }
  }
}

class _NewChatModalContent extends StatefulWidget {
  final ScrollController scrollController;
  final ApiService apiService; 

  const _NewChatModalContent({required this.scrollController, required this.apiService});

  @override
  State<_NewChatModalContent> createState() => _NewChatModalContentState();
}

class _NewChatModalContentState extends State<_NewChatModalContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  List<User> _searchedUsers = []; 

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    if (query.trim().length < 3) {
      setState(() {
        _searchQuery = query;
        _searchedUsers = [];
        _isLoading = false;
      });
      return;
    }
    
    setState(() {
      _searchQuery = query;
      _isLoading = true;
    });

    try {
      final results = await widget.apiService.searchUsers(query); 
      if (mounted) {
        setState(() {
          _searchedUsers = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchedUsers = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8, left: 16, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Yeni Sohbet Başlat', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: 'Kişi ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
              ),
            ),
          ),
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _searchedUsers.isEmpty
                    ? Center(child: Text(_searchQuery.isEmpty ? "Aramaya başlayın..." : "Kullanıcı bulunamadı."))
                    : ListView.builder(
                        controller: widget.scrollController,
                        itemCount: _searchedUsers.length,
                        itemBuilder: (context, index) {
                          final user = _searchedUsers[index];
                          final avatarUrl = user.profileimageurl ?? '';
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                              child: avatarUrl.isEmpty ? const Icon(Icons.person) : null,
                            ),
                            title: Text(user.fullname),
                            subtitle: Text('@${user.username}'),
                            onTap: () {
                              // 🚀 User modelinizdeki 'userid' alanını kontrol edin
                              final int targetId = user.userid ?? 0;
                              debugPrint("DEBUG: Yeni Sohbet Başlat - Hedef ID: $targetId");

                              Navigator.pop(context); // Modalı kapat
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatDetailScreen(
                                    userName: user.fullname,
                                    avatarUrl: avatarUrl,
                                    userId: targetId,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}