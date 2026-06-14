import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/project_detail.dart';
import '../models/task.dart';
import '../services/project_service.dart';
import '../services/task_service.dart';
import '../utils/api_error.dart';

enum DetailStatus { initial, loading, loaded, error }

/// Holds the currently-opened project (with its tasks) and the task mutations.
///
/// [load] drives the screen's loading/error UI. The task methods update the
/// in-memory task list on success and rethrow on failure so the screen can
/// show a SnackBar.
class ProjectDetailProvider extends ChangeNotifier {
  ProjectDetailProvider(this._projectService, this._taskService);

  final ProjectService _projectService;
  final TaskService _taskService;

  static final DateFormat _apiDate = DateFormat('yyyy-MM-dd');

  DetailStatus _status = DetailStatus.initial;
  DetailStatus get status => _status;

  ProjectDetail? _project;
  ProjectDetail? get project => _project;

  String? _error;
  String? get error => _error;

  Future<void> load(String id) async {
    _status = DetailStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _project = await _projectService.getProject(id);
      _status = DetailStatus.loaded;
    } catch (e) {
      _error = describeApiError(e);
      _status = DetailStatus.error;
    }
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    required String description,
    required TaskStatus status,
    DateTime? dueDate,
  }) async {
    final project = _project!;
    final task = await _taskService.createTask(
      projectId: project.id,
      title: title,
      description: description,
      status: status,
      dueDate: _formatDate(dueDate),
    );
    _setTasks([...project.tasks, task]);
  }

  Future<void> updateTask({
    required String taskId,
    required String title,
    required String description,
    required TaskStatus status,
    DateTime? dueDate,
  }) async {
    final updated = await _taskService.updateTask(
      id: taskId,
      title: title,
      description: description,
      status: status,
      dueDate: _formatDate(dueDate),
    );
    _replaceTask(updated);
  }

  /// Status-only change: re-sends the task unchanged except for [status]
  /// (the API's PUT is a full update).
  Future<void> changeStatus(Task task, TaskStatus status) async {
    final updated = await _taskService.updateTask(
      id: task.id,
      title: task.title,
      description: task.description,
      status: status,
      dueDate: _formatDate(task.dueDate),
    );
    _replaceTask(updated);
  }

  Future<void> deleteTask(String taskId) async {
    await _taskService.deleteTask(taskId);
    final project = _project!;
    _setTasks(project.tasks.where((t) => t.id != taskId).toList());
  }

  void _replaceTask(Task updated) {
    final project = _project!;
    _setTasks([
      for (final t in project.tasks)
        if (t.id == updated.id) updated else t,
    ]);
  }

  void _setTasks(List<Task> tasks) {
    final p = _project!;
    _project = ProjectDetail(
      id: p.id,
      name: p.name,
      description: p.description,
      createdAt: p.createdAt,
      tasks: tasks,
    );
    notifyListeners();
  }

  String? _formatDate(DateTime? date) =>
      date == null ? null : _apiDate.format(date);
}
