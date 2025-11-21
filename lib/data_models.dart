// The data models are kept here, separate from the UI.
class Course {
  String title;
  int creditHours;
  String instructor;
  String description;
  String schedule;
  int priority; // 0 = low, 1 = medium, 2 = high (editable)

  /// Map of assessment type -> weight (0.0 - 1.0). e.g. {'quiz':0.2, 'midterm':0.3}
  Map<String, double> weightages;

  /// List of scores: each score has a type and a value (0-100)
  List<AssessmentScore> scores;
  
  /// Documents uploaded for this course
  List<CourseDocument> documents;

  Course(
    this.title,
    this.creditHours, {
    this.instructor = '',
    this.description = '',
    this.schedule = '',
    this.priority = 1,
    Map<String, double>? weightages,
    List<AssessmentScore>? scores,
  }) : weightages = weightages ?? {}, scores = scores ?? [], documents = [] {
  }
}

class AssessmentScore {
  String type;
  double value; // 0-100

  AssessmentScore({required this.type, required this.value});
}

class CourseDocument {
  String name;
  String url;
  String uploadedBy; // user id or display name
  DateTime uploadedAt;

  CourseDocument({required this.name, required this.url, required this.uploadedBy, DateTime? uploadedAt}) : uploadedAt = uploadedAt ?? DateTime.now();
}

class Task {
  String description;
  String period; // 'Today' or 'This Week'
  bool isCompleted;

  Task(this.description, this.period, {this.isCompleted = false});
}

class Reminder {
  String description;
  DateTime date;

  Reminder(this.description, this.date);
}