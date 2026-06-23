import os

def create_file(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(content)

base_path = "lib"

# Models
create_file(f"{base_path}/models/user.dart", """
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}
""")

create_file(f"{base_path}/models/tag.dart", """
class Tag {
  final int id;
  final String name;
  final String color;

  Tag({required this.id, required this.name, required this.color});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      color: json['color'] ?? '',
    );
  }
}
""")

create_file(f"{base_path}/models/folder.dart", """
class Folder {
  final int id;
  final String name;
  final int? parentId;
  final bool isPrivate;
  final String createdAt;
  final String updatedAt;

  Folder({
    required this.id,
    required this.name,
    this.parentId,
    required this.isPrivate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'],
      name: json['name'],
      parentId: json['parentId'],
      isPrivate: json['isPrivate'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
""")

create_file(f"{base_path}/models/part.dart", """
class Part {
  final int id;
  final int partNumber;
  final int channelMsgId;
  final String fileName;
  final int fileSize;
  final String uploadedAt;
  final bool hasThumb;
  final String? streamUrl;

  Part({
    required this.id,
    required this.partNumber,
    required this.channelMsgId,
    required this.fileName,
    required this.fileSize,
    required this.uploadedAt,
    required this.hasThumb,
    this.streamUrl,
  });

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      id: json['id'] ?? json['partId'], // handle stream-info Part payload vs detail Part payload
      partNumber: json['partNumber'],
      channelMsgId: json['channelMsgId'],
      fileName: json['fileName'],
      fileSize: json['fileSize'] ?? 0,
      uploadedAt: json['uploadedAt'] ?? '',
      hasThumb: json['hasThumb'] ?? false,
      streamUrl: json['streamUrl'],
    );
  }
}
""")

create_file(f"{base_path}/models/item.dart", """
import 'part.dart';

class Item {
  final int id;
  final String slug;
  final String title;
  final String kind;
  final int totalParts;
  final int totalSize;
  final bool isFavorite;
  final bool isPrivate;
  final String dateAdded;
  final String updatedAt;
  final String? deletedAt;
  final int? folderId;
  final List<dynamic> tags; // can be int array or string array
  final bool hasThumb;
  final int? firstPartId;
  final String? firstPartFileName;
  final List<Part>? parts;

  Item({
    required this.id,
    required this.slug,
    required this.title,
    required this.kind,
    required this.totalParts,
    required this.totalSize,
    required this.isFavorite,
    required this.isPrivate,
    required this.dateAdded,
    required this.updatedAt,
    this.deletedAt,
    this.folderId,
    required this.tags,
    required this.hasThumb,
    this.firstPartId,
    this.firstPartFileName,
    this.parts,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      slug: json['slug'],
      title: json['title'],
      kind: json['kind'],
      totalParts: json['totalParts'],
      totalSize: json['totalSize'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      isPrivate: json['isPrivate'] ?? false,
      dateAdded: json['dateAdded'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      deletedAt: json['deletedAt'],
      folderId: json['folderId'],
      tags: json['tags'] ?? [],
      hasThumb: json['hasThumb'] ?? false,
      firstPartId: json['firstPartId'],
      firstPartFileName: json['firstPartFileName'],
      parts: json['parts'] != null ? (json['parts'] as List).map((p) => Part.fromJson(p)).toList() : null,
    );
  }
}
""")

create_file(f"{base_path}/models/drive_response.dart", """
import 'folder.dart';
import 'item.dart';
import 'tag.dart';

class DriveResponse {
  final List<Item> files;
  final List<Folder> folders;
  final List<Tag> tags;

  DriveResponse({required this.files, required this.folders, required this.tags});

  factory DriveResponse.fromJson(Map<String, dynamic> json) {
    return DriveResponse(
      files: (json['files'] as List?)?.map((i) => Item.fromJson(i)).toList() ?? [],
      folders: (json['folders'] as List?)?.map((i) => Folder.fromJson(i)).toList() ?? [],
      tags: (json['tags'] as List?)?.map((i) => Tag.fromJson(i)).toList() ?? [],
    );
  }
}
""")

# Services
create_file(f"{base_path}/services/token_storage.dart", """
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
""")

create_file(f"{base_path}/services/api_client.dart", """
import 'package:dio/dio.dart';
import 'token_storage.dart';

class ApiClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://drive.tncp.web.id/papi',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  static void init() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  static Dio get dio => _dio;
}
""")

create_file(f"{base_path}/services/auth_service.dart", """
import 'package:flutter/material.dart';
import 'api_client.dart';
import 'token_storage.dart';
import '../models/user.dart';
import 'package:dio/dio.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = true;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<void> checkAuth() async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      final response = await ApiClient.dio.get('/auth/me');
      _currentUser = User.fromJson(response.data);
    } catch (e) {
      await TokenStorage.deleteToken();
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await ApiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final token = response.data['token'];
      await TokenStorage.saveToken(token);
      _currentUser = User.fromJson(response.data['user']);
      notifyListeners();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      final response = await ApiClient.dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      final token = response.data['token'];
      await TokenStorage.saveToken(token);
      _currentUser = User.fromJson(response.data['user']);
      notifyListeners();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Register failed');
    }
  }

  Future<void> logout() async {
    await TokenStorage.deleteToken();
    _currentUser = null;
    notifyListeners();
  }
}
""")

create_file(f"{base_path}/services/drive_service.dart", """
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
      final response = await ApiClient.dio.get('/drive', queryParameters: {'space': space});
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
    
    final items = _currentDrive!.files.where((f) => f.folderId == _currentFolderId && f.deletedAt == null).toList();
    final folders = _currentDrive!.folders.where((f) => f.parentId == _currentFolderId).toList();
    
    return [...folders, ...items];
  }
  
  Future<List<Item>> search(String q) async {
    final response = await ApiClient.dio.get('/search', queryParameters: {
      'q': q,
      'space': _currentSpace
    });
    return (response.data as List).map((i) => Item.fromJson(i)).toList();
  }

  Future<Item> fetchItemDetail(int id) async {
    final response = await ApiClient.dio.get('/items/$id');
    return Item.fromJson(response.data);
  }
}
""")

create_file(f"{base_path}/services/stream_service.dart", """
import 'api_client.dart';

class StreamService {
  static Future<Map<String, dynamic>> fetchStreamInfo(int itemId) async {
    final response = await ApiClient.dio.get('/items/$itemId/stream-info');
    return response.data;
  }
}
""")

print("Models and Services generated successfully.")
