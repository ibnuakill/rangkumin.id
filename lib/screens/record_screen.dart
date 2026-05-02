import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../models/note_model.dart';
import 'result_screen.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final AudioService _audioService = AudioService();
  final ApiService _apiService = ApiService();

  bool _isRecording = false;
  bool _isProcessing = false;
  String _status = 'Tekan tombol untuk mulai merekam';
  int _recordSeconds = 0;

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopAndProcess();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin mikrofon diperlukan')),
        );
      }
      return;
    }

    await _audioService.startRecording();
    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
      _status = 'Sedang merekam...';
    });

    // timer
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isRecording || !mounted) return false;
      if (mounted) setState(() => _recordSeconds++);
      return true;
    });
  }

  Future<void> _stopAndProcess() async {
    final audioFile = await _audioService.stopRecording();
    setState(() {
      _isRecording = false;
      _status = 'Memproses audio...';
      _isProcessing = true;
    });

    if (audioFile != null) {
      await _processAudio(audioFile);
    }
  }

  Future<void> _pickAndProcess() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      setState(() {
        _isProcessing = true;
        _status = 'Memproses file...';
      });
      await _processAudio(file);
    }
  }

  Future<void> _processAudio(File audioFile) async {
    try {
      setState(() => _status = 'Mentranskripsi audio...');
      final transcript = await _apiService.transcribeAudio(audioFile);

      setState(() => _status = 'Membuat ringkasan...');
      final summary = await _apiService.summarizeText(transcript.transcript);

      final note = NoteModel(
        title:
            'Catatan ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        transcript: transcript.transcript,
        summary: summary.summary,
        duration: transcript.duration?.toInt(),
      );

      final saved = await _apiService.createNote(note);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ResultScreen(note: saved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _status = 'Tekan tombol untuk mulai merekam';
          _recordSeconds = 0;
        });
      }
    }
  }

  String _formatTimer(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('RangkuminID'), centerTitle: true),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitWave(color: color.primary, size: 50),
                  const SizedBox(height: 24),
                  Text(
                    _status,
                    style: TextStyle(color: color.primary, fontSize: 16),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isRecording ? Icons.mic : Icons.mic_none,
                    size: 80,
                    color: _isRecording ? Colors.red : color.primary,
                  ),
                  const SizedBox(height: 16),
                  if (_isRecording)
                    Text(
                      _formatTimer(_recordSeconds),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 48),
                  GestureDetector(
                    onTap: _toggleRecording,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording ? Colors.red : color.primary,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? Colors.red : color.primary)
                                .withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: _isRecording ? null : _pickAndProcess,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload File Audio'),
                  ),
                ],
              ),
            ),
    );
  }
}
