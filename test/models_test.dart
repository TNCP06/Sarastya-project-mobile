import 'package:flutter_test/flutter_test.dart';
import 'package:saradrive/models/user.dart';
import 'package:saradrive/models/folder.dart';
import 'package:saradrive/models/item.dart';

void main() {
  group('Models JSON Serialization Tests', () {
    test('User.fromJson - parses valid json correctly', () {
      final json = {'id': 1, 'name': 'John Doe', 'email': 'john@example.com'};

      final user = User.fromJson(json);

      expect(user.id, 1);
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
    });

    test('Folder.fromJson - parses valid json with default fallbacks', () {
      final json = {'id': 10, 'name': 'My Documents', 'parentId': null};

      final folder = Folder.fromJson(json);

      expect(folder.id, 10);
      expect(folder.name, 'My Documents');
      expect(folder.parentId, null);
      expect(
        folder.isPrivate,
        false,
        reason: 'isPrivate should fallback to false',
      );
      expect(
        folder.createdAt,
        '',
        reason: 'createdAt should fallback to empty string',
      );
    });

    test('Item.fromJson - parses valid json with complex structures', () {
      final json = {
        'id': 100,
        'slug': 'test-item',
        'title': 'Test Item',
        'kind': 'video',
        'totalParts': 3,
        'totalSize': 1024,
        // intentionally omitting isFavorite to test fallback
        'tags': ['anime', 'action'],
      };

      final item = Item.fromJson(json);

      expect(item.id, 100);
      expect(item.slug, 'test-item');
      expect(item.title, 'Test Item');
      expect(item.kind, 'video');
      expect(item.totalParts, 3);
      expect(item.totalSize, 1024);
      expect(
        item.isFavorite,
        false,
        reason: 'isFavorite should fallback to false',
      );
      expect(item.isPrivate, false);
      expect(item.tags.length, 2);
      expect(item.tags, contains('anime'));
      expect(item.parts, null, reason: 'parts array is not provided');
    });
  });
}
