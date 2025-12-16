import 'package:binu_frontend/screens/chat_detail_screen.dart'; 
import 'package:flutter/material.dart';

// 💡 Dinamik veri çekimi için gerekli importlar
import 'package:binu_frontend/services/api_service.dart';
import 'package:binu_frontend/models/post_model.dart'; // User modelinizin bulunduğu dosya

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

// -----------------------------------------------------
// MESAJ EKRANI STATE'İ
// -----------------------------------------------------

class _MessagesScreenState extends State<MessagesScreen> {
  final ApiService _apiService = ApiService();
  
  // 🚀 YENİ: Dinamik konuşma listesini tutacak state
  List<Map<String, dynamic>> _conversations = []; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  // -----------------------------------------------------
  // 🚀 METOT: Konuşmaları API'den Çekme
  // -----------------------------------------------------
  Future<void> _fetchConversations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 💡 ApiService.fetchConversations metodunu çağırıyoruz
      final List<Map<String, dynamic>> fetchedData = await _apiService.fetchConversations();
      
      if (mounted) {
        setState(() {
          _conversations = fetchedData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Konuşma listesi çekilirken hata: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konuşmalar yüklenemedi: ${e.toString()}')),
        );
      }
    }
  }

  // -----------------------------------------------------
  // Yeni Sohbet Modalını Açma (Aynı Kalır)
  // -----------------------------------------------------
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
                        
                        // 🚀 GÜVENLİ VERİ ÇEKİMİ
                        // Karşı kullanıcının bilgileri 'other_user' map'i içindedir (backend'de MessageSummarySerializer kullanıldıysa)
                        final otherUser = conversation['other_user'] as Map<String, dynamic>?;
                        
                        final unreadCount = conversation['unreadCount'] as int? ?? 0;
                        final String name = otherUser?['fullname'] as String? ?? conversation['name'] as String? ?? 'Bilinmeyen Kullanıcı';
                        final String lastMessage = conversation['messagecontent'] as String? ?? conversation['lastMessage'] as String? ?? 'Mesaj yok.';
                        
                        // Zaman formatını backend'den gelen sentat veya time'dan alın
                        final String time = conversation['sentat'] != null ? _formatTimeAgo(DateTime.parse(conversation['sentat'])) : conversation['time'] as String? ?? '';
                        
                        final String avatarUrl = otherUser?['profileimageurl'] as String? ?? conversation['avatar'] as String? ?? '';
                        final bool hasAvatar = avatarUrl.isNotEmpty;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                            backgroundColor: colorScheme.surfaceVariant, 
                            child: !hasAvatar ? Icon(Icons.person, color: colorScheme.onSurface) : null,
                          ),
                          title: Text(
                            name,
                            style: theme.textTheme.titleMedium, 
                          ),
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
                              Text(
                                time, 
                                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)
                              ),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatDetailScreen(
                                  userName: name,
                                  avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : 'https://i.pravatar.cc/150?img=default', 
                                  // userId: otherUser?['userid'], 
                                ),
                              ),
                            );
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
  
  // 💡 API'den gelen ISO 8601 tarihini formatlamak için helper metot
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${difference.inDays ~/ 7} hafta önce';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'şimdi';
    }
  }
}


// =================================================================
// 🚀 YENİ WIDGET: Yeni Sohbet Modal İçeriği (Dinamik Arama)
// =================================================================

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
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // API üzerinden kullanıcı aramasını gerçekleştirir
  void _performSearch(String query) async {
    // Sadece 3 karakterden sonra arama yap
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
      print("Kullanıcı arama hatası: $e");
      if (mounted) {
        setState(() {
          _searchedUsers = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kullanıcı arama başarısız: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final List<User> filteredUsers = _searchedUsers;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      child: Column(
        children: [
          // Başlık ve Kapatma Butonu
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8, left: 16, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Yeni Sohbet Başlat',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Arama Çubuğu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _performSearch(value); 
              },
              decoration: InputDecoration(
                hintText: 'Kişi ara (Ad veya Kullanıcı Adı)',
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Kullanıcı Listesi
          Expanded(
            child: _isLoading 
                ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
                : filteredUsers.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty 
                              ? "Aramaya başlamak için en az 3 harf girin." 
                              : "Aradığınız kriterde kullanıcı bulunamadı.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        controller: widget.scrollController,
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          final hasAvatar = user.profileimageurl != null && user.profileimageurl!.isNotEmpty;
                          
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundImage: hasAvatar ? NetworkImage(user.profileimageurl!) : null,
                              backgroundColor: colorScheme.primaryContainer,
                              child: !hasAvatar ? Icon(Icons.person, color: colorScheme.onPrimaryContainer) : null,
                            ),
                            title: Text(user.fullname, style: theme.textTheme.titleMedium),
                            subtitle: Text('@${user.username}', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                            onTap: () {
                              // Sohbet başlatma aksiyonu
                              Navigator.pop(context); // Modalı kapat
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatDetailScreen(
                                    userName: user.fullname,
                                    avatarUrl: user.profileimageurl ?? Icons.person.toString(), 
                                    // userId: user.userid, 
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