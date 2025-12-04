import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // Tarih formatlama için bu paket gerekebilir

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _projectTitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Takım üyeleri için bir liste
  final List<String> _teamMembers = ['Ayşe Yılmaz', 'Can Demir'];

  Future<void> _selectDate() async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      // Tema renklerini DatePicker'a uygula
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: colorScheme.primary, // Vurgu rengi
              onPrimary: colorScheme.onPrimary, // Başlık metin rengi
              surface: colorScheme.surface, // Arka plan
              onSurface: colorScheme.onSurface, // Takvim metin rengi
            ),
            // Metin stillerini korumak için
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary, // Buton metin rengi (OK/CANCEL)
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // İntL paketini kullanmadığımız için basit formatlama
        _dateController.text = "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
      });
    }
  }

  void _addTeamMember() {
    // Burada gerçekte bir dialog açılıp üye seçilmeli veya girilmelidir.
    setState(() {
      _teamMembers.add('Yeni Üye');
    });
  }

  void _removeTeamMember(String memberName) {
    setState(() {
      _teamMembers.remove(memberName);
    });
  }

  void _saveReport() {
    if (_formKey.currentState!.validate()) {
      // Başarı mesajı (temadan renkleri al)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Rapor başarıyla kaydedildi!', style: TextStyle(color: Colors.white)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    
    return Scaffold(
      // Arka plan rengini temadan al
      backgroundColor: theme.scaffoldBackgroundColor,
      // AppBar ekleyelim
      appBar: AppBar(
        title: const Text('Yeni Proje Raporu'),
        elevation: 0.5,
        // Renkler AppTheme'dan geliyor.
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Proje Adı
              _buildSectionTitle('Proje Adı', theme),
              TextFormField(
                controller: _projectTitleController,
                // Decoration stili AppTheme'dan geliyor.
                decoration: const InputDecoration(
                  hintText: 'Örn: Mobil Uygulama Geliştirme',
                ),
                validator: (value) => value == null || value.isEmpty ? 'Proje adı gerekli.' : null,
              ),
              const SizedBox(height: 24),
              
              // Açıklama
              _buildSectionTitle('Açıklama', theme),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Projenin hedeflerini, kapsamını ve metodolojisini açıklayın.',
                  alignLabelWithHint: true,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Açıklama gerekli.' : null,
              ),
              const SizedBox(height: 24),

              // Teslim Tarihi
              _buildSectionTitle('Teslim Tarihi', theme),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _selectDate,
                // Decoration stili AppTheme'dan geliyor.
                decoration: InputDecoration(
                  hintText: 'GG.AA.YYYY',
                  prefixIcon: Icon(Icons.calendar_today_outlined, color: colorScheme.onSurface.withOpacity(0.6)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Tarih gerekli.' : null,
              ),
              const SizedBox(height: 24),

              // Takım Üyeleri
              _buildSectionTitle('Takım Üyeleri', theme),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  ..._teamMembers.map((member) => _buildMemberChip(member, colorScheme, theme)),
                  ActionChip(
                    avatar: Icon(Icons.add, color: colorScheme.onPrimary), // Buton rengi
                    label: const Text('Üye Ekle'),
                    // Arka plan rengi temadan al (primary)
                    backgroundColor: colorScheme.primary,
                    // Metin rengi temadan al (onPrimary)
                    labelStyle: TextStyle(color: colorScheme.onPrimary),
                    onPressed: _addTeamMember,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // İlerleme Durumu
              _buildSectionTitle('İlerleme Durumu', theme),
              TextFormField(
                controller: _statusController,
                // Decoration stili AppTheme'dan geliyor.
                decoration: const InputDecoration(
                  hintText: 'Örn: %75 tamamlandı, test aşamasında',
                ),
              ),

              // Kaydet Butonu
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveReport,
                  // Stil bloğu kaldırıldı. AppTheme'dan gelecek.
                  child: const Text('Raporu Kaydet', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Başlıklar için yardımcı bir widget
  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontSize: 16, 
          fontWeight: FontWeight.bold,
          // Metin rengini temadan al
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  // Takım üyesi Chip'i
  Widget _buildMemberChip(String memberName, ColorScheme colorScheme, ThemeData theme) {
    return Chip(
      label: Text(memberName),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      // Chip'in arka plan rengi
      backgroundColor: colorScheme.surfaceVariant,
      onDeleted: () => _removeTeamMember(memberName),
      // Silme ikonu rengini temadan al
      deleteIconColor: colorScheme.onSurfaceVariant,
    );
  }
}