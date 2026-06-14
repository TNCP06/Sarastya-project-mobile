/// The lifecycle state of a task. [apiValue] is the exact string the API
/// expects/returns; [label] is the human-friendly form for the UI.
enum TaskStatus {
  todo('todo', 'To do'),
  inProgress('in_progress', 'In progress'),
  done('done', 'Done');

  const TaskStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static TaskStatus fromApi(String? value) {
    return TaskStatus.values.firstWhere(
      (s) => s.apiValue == value,
      orElse: () => TaskStatus.todo,
    );
  }
}

/// A task belonging to a project.
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.dueDate,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final DateTime? dueDate;
  final DateTime? createdAt;

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: TaskStatus.fromApi(json['status'] as String?),
      dueDate: DateTime.tryParse(json['dueDate']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
