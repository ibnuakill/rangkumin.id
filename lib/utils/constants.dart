class AppConstants {
  // Base URL backend - ganti IP sesuai komputer kamu
  // Kalau test di emulator pakai 10.0.2.2
  // Kalau test di HP fisik pakai IP WiFi komputer kamu (cek dengan ipconfig)
  static const String baseUrl = 'http://10.60.169.21:8000/api/v1';

  // Endpoints
  static const String transcribeEndpoint = '/transcribe';
  static const String summarizeEndpoint = '/summarize';
  static const String notesEndpoint = '/notes';

  // App info
  static const String appName = 'RangkuminID';

  // Audio
  static const List<String> allowedAudioFormats = ['mp3', 'wav', 'm4a', 'ogg'];
}
