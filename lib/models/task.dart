class Task {
  final int? id;
  final String title;
  final bool isCompleted;

  Task({this.id, required this.title, this.isCompleted = false});

  // Convert a Task object into a map for SQLite.
  Map<String, Object?> toMap() {
    return {'id': id, 'title': title, 'isCompleted': isCompleted ? 1 : 0};
  }

  // Convert a SQLite record into a Task object.
  factory Task.fromMap(Map<String, Object?> map) {
    return Task(
      id: map['id'] as int,
      title: map['title'] as String,
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
