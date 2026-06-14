import '../models/task.dart';
import 'api_client.dart';

/// Wraps the task endpoints of the API. Tasks are created under a project, but
/// updated/deleted by their own id.
class TaskService {
  TaskService(this._apiClient);

  final ApiClient _apiClient;

  /// POST /api/projects/{projectId}/tasks → 201 with the created task.
  Future<Task> createTask({
    required String projectId,
    required String title,
    required String description,
    required TaskStatus status,
    String? dueDate,
  }) async {
    final res = await _apiClient.dio.post<Map<String, dynamic>>(
      '/projects/$projectId/tasks',
      data: {
        'title': title,
        'description': description,
        'status': status.apiValue,
        'dueDate': dueDate,
      },
    );
    return Task.fromJson(res.data!);
  }

  /// PUT /api/tasks/{id} → 200. Full update — also used for status changes.
  Future<Task> updateTask({
    required String id,
    required String title,
    required String description,
    required TaskStatus status,
    String? dueDate,
  }) async {
    final res = await _apiClient.dio.put<Map<String, dynamic>>(
      '/tasks/$id',
      data: {
        'title': title,
        'description': description,
        'status': status.apiValue,
        'dueDate': dueDate,
      },
    );
    return Task.fromJson(res.data!);
  }

  /// DELETE /api/tasks/{id} → 204.
  Future<void> deleteTask(String id) async {
    await _apiClient.dio.delete<void>('/tasks/$id');
  }
}
