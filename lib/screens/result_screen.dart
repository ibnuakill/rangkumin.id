import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/note_model.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';
import 'summary_screen.dart';

class ResultScreen extends StatefulWidget {
  final NoteModel note;
  const ResultScreen({super.key, required this.note});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final ApiService _apiService = ApiService();
  late TextEditingController _titleController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveTitle() async {
    if (widget.note.id == null) return;
    setState(() => _isSaving = true);
    try {
      await _apiService.updateNote(widget.note.id!, {
        'title': _titleController.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Judul berhasil disimpan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final note = widget.note;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Transkripsi'),
        centerTitle: true,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save_outlined),
              onPressed: _saveTitle,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // judul
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Catatan',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 8),
            if (note.createdAt != null)
              Text(
                Helpers.formatDate(note.createdAt!),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            const SizedBox(height: 24),

            // ringkasan
            if (note.summary != null) ...[
              Row(
                children: [
                  Icon(Icons.summarize, color: color.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Ringkasan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color.primary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SummaryScreen(note: note),
                      ),
                    ),
                    child: const Text('Lihat Detail'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  Helpers.truncateText(note.summary!, 200),
                  style: TextStyle(color: color.onPrimaryContainer),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // transkripsi
            Row(
              children: [
                const Icon(Icons.text_snippet),
                const SizedBox(width: 8),
                const Text(
                  'Transkripsi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: note.transcript ?? ''),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Teks disalin')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(note.transcript ?? '-'),
            ),
          ],
        ),
      ),
    );
  }
}
