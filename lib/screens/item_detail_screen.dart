import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/drive_service.dart';
import '../models/item.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailScreen extends StatefulWidget {
  final String id;
  const ItemDetailScreen({super.key, required this.id});

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  Item? _item;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final item = await context.read<DriveService>().fetchItemDetail(
        int.parse(widget.id),
      );
      setState(() {
        _item = item;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _download() async {
    if (_item == null) return;
    // Download uses the bot deep link based on slug
    final url = Uri.parse(
      'https://t.me/SarastyaCloudDriveBot?start=dl-${_item!.slug}',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch Telegram')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return Scaffold(
        appBar: AppBar(title: Text('Loading')),
        body: Center(child: CircularProgressIndicator()),
      );
    if (_error != null)
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text(_error!)),
      );
    if (_item == null)
      return Scaffold(
        appBar: AppBar(title: Text('Not found')),
        body: Center(child: Text('Item not found')),
      );

    return Scaffold(
      appBar: AppBar(title: Text(_item!.title)),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(title: Text('Type'), subtitle: Text(_item!.kind)),
          ListTile(
            title: Text('Total Parts'),
            subtitle: Text('${_item!.totalParts}'),
          ),
          ListTile(
            title: Text('Size'),
            subtitle: Text(
              '${(_item!.totalSize / 1024 / 1024).toStringAsFixed(2)} MB',
            ),
          ),
          ListTile(title: Text('Date Added'), subtitle: Text(_item!.dateAdded)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _download,
                icon: Icon(Icons.download),
                label: Text('Download via Bot'),
              ),
              if (_item!.kind == 'media')
                ElevatedButton.icon(
                  onPressed: () => context.push('/player/${_item!.id}'),
                  icon: Icon(Icons.play_arrow),
                  label: Text('Play Video'),
                ),
            ],
          ),
          SizedBox(height: 20),
          Text('Parts:', style: Theme.of(context).textTheme.titleLarge),
          if (_item!.parts != null)
            ..._item!.parts!.map(
              (p) => ListTile(
                leading: CircleAvatar(child: Text('${p.partNumber}')),
                title: Text(p.fileName),
                subtitle: Text(
                  '${(p.fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
