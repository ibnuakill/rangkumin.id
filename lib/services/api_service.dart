import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/note_model.dart';
import '../models/transcript.dart';
import '../models/summary.dart';
import '../utils/constants.dart';

class ApiService {
  final String baseUrl = AppConstants.baseUrl;

  // ── TRANSCRIBE ──────────────────────────────────────────
  Future<TranscriptModel> transcribeAudio(File audioFile) async {
    final uri = Uri.parse('$baseUrl${AppConstants.transcribeEndpoint}');
    final request = http.MultipartRequest('POST', uri);

    final ext = audioFile.path.split('.').last.toLowerCase();
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        audioFile.path,
        contentType: MediaType('audio', ext),
      ),
    );

    // Tambah timeout 3 menit
    request.headers['Connection'] = 'keep-alive';
    final streamedResponse = await request.send().timeout(
      const Duration(minutes: 3),
    );
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return TranscriptModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Transkripsi gagal: ${response.body}');
    }
  }

  // ── SUMMARIZE ───────────────────────────────────────────
  Future<SummaryModel> summarizeText(String transcript) async {
    final uri = Uri.parse('$baseUrl${AppConstants.summarizeEndpoint}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'transcript': transcript}),
    );

    if (response.statusCode == 200) {
      return SummaryModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Summarize gagal: ${response.body}');
    }
  }

  // ── NOTES CRUD ──────────────────────────────────────────
  Future<List<NoteModel>> getAllNotes() async {
    final uri = Uri.parse('$baseUrl${AppConstants.notesEndpoint}');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => NoteModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil catatan');
    }
  }

  Future<NoteModel> createNote(NoteModel note) async {
    final uri = Uri.parse('$baseUrl${AppConstants.notesEndpoint}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(note.toJson()),
    );

    if (response.statusCode == 200) {
      return NoteModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal membuat catatan');
    }
  }

  Future<NoteModel> updateNote(int id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl${AppConstants.notesEndpoint}/$id');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return NoteModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal update catatan');
    }
  }

  Future<void> deleteNote(int id) async {
    final uri = Uri.parse('$baseUrl${AppConstants.notesEndpoint}/$id');
    final response = await http.delete(uri);

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus catatan');
    }
  }
}
