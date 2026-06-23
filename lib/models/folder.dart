
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
