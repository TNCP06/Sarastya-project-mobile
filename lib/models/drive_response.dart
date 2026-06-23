import 'folder.dart';
import 'item.dart';
import 'tag.dart';

class DriveResponse {
  final List<Item> files;
  final List<Folder> folders;
  final List<Tag> tags;

  DriveResponse({
    required this.files,
    required this.folders,
    required this.tags,
  });

  factory DriveResponse.fromJson(Map<String, dynamic> json) {
    return DriveResponse(
      files:
          (json['files'] as List?)?.map((i) => Item.fromJson(i)).toList() ?? [],
      folders:
          (json['folders'] as List?)?.map((i) => Folder.fromJson(i)).toList() ??
          [],
      tags: (json['tags'] as List?)?.map((i) => Tag.fromJson(i)).toList() ?? [],
    );
  }
}
