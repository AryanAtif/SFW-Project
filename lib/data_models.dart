// The data models are kept here, separate from the UI.
class Course {
  final String title;
  final int creditHours;

  Course(this.title, this.creditHours);
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