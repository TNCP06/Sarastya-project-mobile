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
      parts: json['parts'] != null
          ? (json['parts'] as List).map((p) => Part.fromJson(p)).toList()
          : null,
    );
  }
}
