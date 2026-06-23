import 'package:flutter/material.dart';
import 'api_client.dart';
import '../models/drive_response.dart';
import '../models/item.dart';

class DriveService extends ChangeNotifier {
  DriveResponse? _currentDrive;
  bool _isLoading = false;
  String? _error;
  int? _currentFolderId;
  String _currentSpace = 'main'; // main or private

  DriveResponse? get currentDrive => _currentDrive;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get currentFolderId => _currentFolderId;

  Future<void> fetchDrive({String space = 'main'}) async {
    _isLoading = true;
    _error = null;
    _currentSpace = space;
    notifyListeners();
    try {
      final response = await ApiClient.dio.get(
        '/drive',
        queryParameters: {'space': space},
      );
      _currentDrive = DriveResponse.fromJson(response.data);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void navigateToFolder(int? folderId) {
    _currentFolderId = folderId;
    notifyListeners();
  }

  List<dynamic> get currentItems {
    if (_currentDrive == null) return [];

    final items = _currentDrive!.files
        .where((f) => f.folderId == _currentFolderId && f.deletedAt == null)
        .toList();
    final folders = _currentDrive!.folders
        .where((f) => f.parentId == _currentFolderId)
        .toList();

    return [...folders, ...items];
  }

  Future<List<Item>> search(String q) async {
    final response = await ApiClient.dio.get(
      '/search',
      queryParameters: {'q': q, 'space': _currentSpace},
    );
    return (response.data as List).map((i) => Item.fromJson(i)).toList();
  }

  Future<Item> fetchItemDetail(int id) async {
    final response = await ApiClient.dio.get('/items/$id');
    return Item.fromJson(response.data);
  }
}
