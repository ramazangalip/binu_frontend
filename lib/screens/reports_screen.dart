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
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
      });
    }
  }

  void _addTeamMember() {

    setState(() {
      _teamMembers.add('Yeni Üye');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Proje Adı'),
              TextFormField(
                controller: _projectTitleController,
                decoration: const InputDecoration(
                  hintText: 'Örn: Mobil Uygulama Geliştirme',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              
              _buildSectionTitle('Açıklama'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Projenin hedeflerini, kapsamını ve metodolojisini açıklayın.',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Teslim Tarihi'),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _selectDate,
                decoration: const InputDecoration(
                  hintText: 'GG.AA.YYYY',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Takım Üyeleri'),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  ..._teamMembers.map((member) => Chip(label: Text(member))),
                  ActionChip(
                    avatar: const Icon(Icons.add),
                    label: const Text('Üye Ekle'),
                    onPressed: _addTeamMember,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('İlerleme Durumu'),
              TextFormField(
                controller: _statusController,
                decoration: const InputDecoration(
                  hintText: 'Örn: %75 tamamlandı, test aşamasında',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              // DEĞİŞİKLİK: Buton buraya eklendi
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Raporu kaydetme mantığı
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Raporu Kaydet', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
      // DEĞİŞİKLİK: bottomNavigationBar kaldırıldı
    );
  }

  // Başlıklar için yardımcı bir widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

