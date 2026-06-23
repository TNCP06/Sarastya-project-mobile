import os

def create_file(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(content)

base_path = "lib"

create_file(f"{base_path}/screens/splash_screen.dart", """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final auth = context.read<AuthService>();
    await auth.checkAuth();
    if (auth.isAuthenticated) {
      context.go('/drive');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
""")

create_file(f"{base_path}/screens/login_screen.dart", """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().login(
        _emailController.text,
        _passwordController.text,
      );
      context.go('/drive');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login to Sarastya Drive')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            _isLoading ? CircularProgressIndicator() : ElevatedButton(onPressed: _login, child: Text('Login')),
            TextButton(onPressed: () => context.go('/register'), child: Text('Create an account'))
          ],
        ),
      ),
    );
  }
}
""")

create_file(f"{base_path}/screens/register_screen.dart", """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );
      context.go('/drive');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            _isLoading ? CircularProgressIndicator() : ElevatedButton(onPressed: _register, child: Text('Register')),
            TextButton(onPressed: () => context.pop(), child: Text('Back to Login'))
          ],
        ),
      ),
    );
  }
}
""")

create_file(f"{base_path}/screens/drive_screen.dart", """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/drive_service.dart';
import '../models/folder.dart';
import '../models/item.dart';

class DriveScreen extends StatefulWidget {
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
""")

create_file(f"{base_path}/screens/search_screen.dart", """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/drive_service.dart';
import '../models/item.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<Item> _results = [];
  bool _isLoading = false;

  Future<void> _search() async {
    setState(() => _isLoading = true);
    try {
      final res = await context.read<DriveService>().search(_searchController.text);
      setState(() => _results = res);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Search failed')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(hintText: 'Search...', border: InputBorder.none, hintStyle: TextStyle(color: Colors.white60)),
          style: TextStyle(color: Colors.white),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
        ),
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final item = _results[index];
                return ListTile(
                  leading: Icon(item.kind == 'media' ? Icons.play_circle_outline : Icons.insert_drive_file),
                  title: Text(item.title),
                  onTap: () => context.push('/item/${item.id}'),
                );
              },
            ),
    );
  }
}
""")

create_file(f"{base_path}/screens/item_detail_screen.dart", """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/drive_service.dart';
import '../models/item.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailScreen extends StatefulWidget {
  final String id;
  ItemDetailScreen({required this.id});

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
      final item = await context.read<DriveService>().fetchItemDetail(int.parse(widget.id));
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
    final url = Uri.parse('https://t.me/SarastyaCloudDriveBot?start=dl-${_item!.slug}');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch Telegram')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(appBar: AppBar(title: Text('Loading')), body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(appBar: AppBar(title: Text('Error')), body: Center(child: Text(_error!)));
    if (_item == null) return Scaffold(appBar: AppBar(title: Text('Not found')), body: Center(child: Text('Item not found')));

    return Scaffold(
      appBar: AppBar(title: Text(_item!.title)),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(title: Text('Type'), subtitle: Text(_item!.kind)),
          ListTile(title: Text('Total Parts'), subtitle: Text('${_item!.totalParts}')),
          ListTile(title: Text('Size'), subtitle: Text('${(_item!.totalSize / 1024 / 1024).toStringAsFixed(2)} MB')),
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
            ..._item!.parts!.map((p) => ListTile(
              leading: CircleAvatar(child: Text('${p.partNumber}')),
              title: Text(p.fileName),
              subtitle: Text('${(p.fileSize / 1024 / 1024).toStringAsFixed(2)} MB'),
            )),
        ],
      ),
    );
  }
}
""")

create_file(f"{base_path}/screens/video_player_screen.dart", """
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../services/stream_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String id;
  VideoPlayerScreen({required this.id});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final info = await StreamService.fetchStreamInfo(int.parse(widget.id));
      final parts = info['parts'] as List;
      if (parts.isEmpty) throw Exception('No streamable parts available');
      
      final streamUrl = parts[0]['streamUrl'];
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(streamUrl));
      await _videoPlayerController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
      );
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Player')),
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: Colors.white)))
              : Center(
                  child: Chewie(
                    controller: _chewieController!,
                  ),
                ),
    );
  }
}
""")

create_file(f"{base_path}/main.dart", """
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/drive_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/drive_screen.dart';
import 'screens/search_screen.dart';
import 'screens/item_detail_screen.dart';
import 'screens/video_player_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => DriveService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
      GoRoute(path: '/drive', builder: (context, state) => DriveScreen()),
      GoRoute(path: '/search', builder: (context, state) => SearchScreen()),
      GoRoute(path: '/item/:id', builder: (context, state) => ItemDetailScreen(id: state.pathParameters['id']!)),
      GoRoute(path: '/player/:id', builder: (context, state) => VideoPlayerScreen(id: state.pathParameters['id']!)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sarastya Drive',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
""")

print("Screens and main.dart generated successfully.")
