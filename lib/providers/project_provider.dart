import 'package:flutter/foundation.dart';

import '../models/project.dart';
import '../services/project_service.dart';
import '../utils/api_error.dart';

/// Loading state of the project list.
enum ProjectsStatus { initial, loading, loaded, error }

/// Holds the list of the current user's projects and the CRUD operations.
///
/// [fetchProjects] drives the list's loading/error/empty UI. The mutating
/// methods ([createProject], [updateProject], [deleteProject]) update the
/// in-memory list optimistically on success and rethrow on failure so the
/// calling screen can show a SnackBar.
class ProjectProvider extends ChangeNotifier {
  ProjectProvider(this._service);

  final ProjectService _service;

  ProjectsStatus _status = ProjectsStatus.initial;
  ProjectsStatus get status => _status;

  List<Project> _projects = const [];
  List<Project> get projects => _projects;

  String? _error;
  String? get error => _error;

  bool get isEmpty =>
      _status == ProjectsStatus.loaded && _projects.isEmpty;

  /// Loads (or reloads) the project list.
  Future<void> fetchProjects() async {
    _status = ProjectsStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _projects = await _service.getProjects();
      _status = ProjectsStatus.loaded;
    } catch (e) {
      _error = describeApiError(e);
      _status = ProjectsStatus.error;
    }
    notifyListeners();
  }

  Future<void> createProject({
    required String name,
    required String description,
  }) async {
    final created =
        await _service.createProject(name: name, description: description);
    _projects = [created, ..._projects];
    notifyListeners();
  }

  Future<void> updateProject({
    required String id,
    required String name,
    required String description,
  }) async {
    final updated = await _service.updateProject(
      id: id,
      name: name,
      description: description,
    );
    _projects = [
      for (final p in _projects)
        if (p.id == id) updated else p,
    ];
    notifyListeners();
  }

  Future<void> deleteProject(String id) async {
    await _service.deleteProject(id);
    _projects = _projects.where((p) => p.id != id).toList();
    notifyListeners();
  }
}
