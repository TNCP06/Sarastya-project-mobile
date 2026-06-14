import 'task.dart';

/// A project together with its tasks, as returned by `GET /api/projects/{id}`.
class ProjectDetail {
  const ProjectDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.tasks,
    this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final List<Task> tasks;
  final DateTime? createdAt;

  int get doneCount =>
      tasks.where((t) => t.status == TaskStatus.done).length;

  factory ProjectDetail.fromJson(Map<String, dynamic> json) {
    final rawTasks = (json['tasks'] as List<dynamic>?) ?? const [];
    return ProjectDetail(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      tasks: rawTasks
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
