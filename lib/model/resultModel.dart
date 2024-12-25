class ExamResult {
  final String subject;
  final int obtainedMarks;
  final String remarks;

  ExamResult({
    required this.subject,
    required this.obtainedMarks,
    required this.remarks,
  });


  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      subject: json['subject'],
      obtainedMarks: json['obtainedMarks'],
      remarks: json['remarks'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'obtainedMarks': obtainedMarks,
      'remarks': remarks,
    };
  }
}
