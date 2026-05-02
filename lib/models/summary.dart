class SummaryModel {
  final String summary;

  SummaryModel({required this.summary});

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(summary: json['summary']);
  }
}
