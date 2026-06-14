/// A project as returned by `GET /api/projects` (list view), including the
/// task roll-up counts. The full detail (with tasks) is a separate model used
/// in Checkpoint 4.
class Project {
  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.taskCount,
    required this.doneTaskCount,
    this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final int taskCount;
  final int doneTaskCount;
  final DateTime? createdAt;

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      taskCount: (json['taskCount'] as num?)?.toInt() ?? 0,
      doneTaskCount: (json['doneTaskCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
