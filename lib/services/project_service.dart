import '../models/project.dart';
import '../models/project_detail.dart';
import 'api_client.dart';

/// Wraps the project endpoints of the API.
class ProjectService {
  ProjectService(this._apiClient);

  final ApiClient _apiClient;

  /// GET /api/projects → 200 array of projects with task roll-up counts.
  Future<List<Project>> getProjects() async {
    final res = await _apiClient.dio.get<List<dynamic>>('/projects');
    final list = res.data ?? const [];
    return list
        .map((e) => Project.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/projects/{id} → 200 the project with its tasks (404 if not owned).
  Future<ProjectDetail> getProject(String id) async {
    final res = await _apiClient.dio.get<Map<String, dynamic>>('/projects/$id');
    return ProjectDetail.fromJson(res.data!);
  }

  /// POST /api/projects → 201 with the created project.
  Future<Project> createProject({
    required String name,
    required String description,
  }) async {
    final res = await _apiClient.dio.post<Map<String, dynamic>>(
      '/projects',
      data: {'name': name, 'description': description},
    );
    return Project.fromJson(res.data!);
  }

  /// PUT /api/projects/{id} → 200 with the updated project.
  Future<Project> updateProject({
    required String id,
    required String name,
    required String description,
  }) async {
    final res = await _apiClient.dio.put<Map<String, dynamic>>(
      '/projects/$id',
      data: {'name': name, 'description': description},
    );
    return Project.fromJson(res.data!);
  }

  /// DELETE /api/projects/{id} → 204 (cascade-deletes its tasks).
  Future<void> deleteProject(String id) async {
    await _apiClient.dio.delete<void>('/projects/$id');
  }
}
