
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/drive_service.dart';
import '../models/folder.dart';
import '../models/item.dart';

class DriveScreen extends StatefulWidget {
  const DriveScreen({super.key});

  @override
  _DriveScreenState createState() => _DriveScreenState();
}

class _DriveScreenState extends State<DriveScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriveService>().fetchDrive();
    });
  }

  Future<void> _logout() async {
    await context.read<AuthService>().logout();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final drive = context.watch<DriveService>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Sarastya Drive'),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () => context.push('/search')),
          IconButton(icon: Icon(Icons.logout), onPressed: _logout),
        ],
        leading: drive.currentFolderId != null 
            ? IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
                // Find parent folder id to navigate back
                final folder = drive.currentDrive?.folders.firstWhere((f) => f.id == drive.currentFolderId, orElse: () => Folder(id: 0, name: '', isPrivate: false, createdAt: '', updatedAt: ''));
                drive.navigateToFolder(folder?.parentId);
              })
            : null,
      ),
      body: drive.isLoading
          ? Center(child: CircularProgressIndicator())
          : drive.error != null
              ? Center(child: Text(drive.error!))
              : RefreshIndicator(
                  onRefresh: () => drive.fetchDrive(),
                  child: GridView.builder(
                    padding: EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
                    itemCount: drive.currentItems.length,
                    itemBuilder: (context, index) {
                      final item = drive.currentItems[index];
                      if (item is Folder) {
                        return Card(
                          child: InkWell(
                            onTap: () => drive.navigateToFolder(item.id),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.folder, size: 48, color: Colors.blue),
                                Text(item.name, textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        );
                      } else if (item is Item) {
                        return Card(
                          child: InkWell(
                            onTap: () => context.push('/item/${item.id}'),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(item.kind == 'media' ? Icons.play_circle_outline : Icons.insert_drive_file, size: 48, color: Colors.orange),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(item.title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ),
    );
  }
}
