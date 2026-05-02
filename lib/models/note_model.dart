class NoteModel {
  final int? id;
  final String title;
  final String? transcript;
  final String? summary;
  final String? audioFilename;
  final int? duration;
  final DateTime? createdAt;

  NoteModel({
    this.id,
    required this.title,
    this.transcript,
    this.summary,
    this.audioFilename,
    this.duration,
    this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],
      transcript: json['transcript'],
      summary: json['summary'],
      audioFilename: json['audio_filename'],
      duration: json['duration'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'transcript': transcript,
      'summary': summary,
      'audio_filename': audioFilename,
      'duration': duration,
    };
  }
}
