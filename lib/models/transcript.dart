class TranscriptModel {
  final String transcript;
  final double? duration;
  final String? language;

  TranscriptModel({required this.transcript, this.duration, this.language});

  factory TranscriptModel.fromJson(Map<String, dynamic> json) {
    return TranscriptModel(
      transcript: json['transcript'],
      duration: json['duration']?.toDouble(),
      language: json['language'],
    );
  }
}
