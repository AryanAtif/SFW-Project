// The data models are kept here, separate from the UI.
class Course {
  String title;
  int creditHours;
  String instructor;
  String description;
  String schedule;

  Course(
    this.title, 
    this.creditHours, {
    this.instructor = '',
    this.description = '',
    this.schedule = '',
  });
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