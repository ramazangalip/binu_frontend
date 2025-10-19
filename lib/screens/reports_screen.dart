import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final TextEditingController _projectTitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedFile;
  bool _isSending = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'pptx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _sendReport() async {
    if (_projectTitleController.text.isEmpty || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen proje adı ve dosya seçin.")),
      );
      return;
    }

    setState(() => _isSending = true);

    // Burada gerçek backend (örneğin Firebase veya API) çağrısı yapılabilir
    await Future.delayed(const Duration(seconds: 2)); // Simülasyon

    setState(() => _isSending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Rapor başarıyla gönderildi!")),
    );

    // Alanları temizle
    _projectTitleController.clear();
    _descriptionController.clear();
    setState(() => _selectedFile = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Proje & Rapor Gönderimi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Raporunuzu veya projenizi yükleyin.\nGönderim sonrası öğretim görevlisi tarafından incelenecektir.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _projectTitleController,
              decoration: InputDecoration(
                labelText: 'Proje / Rapor Başlığı',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Açıklama (isteğe bağlı)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text("Dosya Seç (.pdf, .docx, .pptx)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 10),
            if (_selectedFile != null)
              Text(
                "Seçilen dosya: ${_selectedFile!.path.split('/').last}",
                style: const TextStyle(color: Colors.black87),
              ),

            const SizedBox(height: 30),
            _isSending
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _sendReport,
                    icon: const Icon(Icons.send),
                    label: const Text(
                      "Gönder",
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
