import 'package:flutter/material.dart';
import 'note_detail_screen.dart';
import 'note_add_screen.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/secure_storage.dart';
import 'package:provider/provider.dart';

class SupabaseProvider extends ChangeNotifier {
  final SupabaseClient client; 

  SupabaseProvider(this.client);
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final secureStorage = SecureSupabaseStorage();

  await Supabase.initialize(
    url: 'https://zhhfhmqpyqdiqibefjzq.supabase.co',
    anonKey: 'sb_publishable_QJfXY-z_gGq8MWkysUW4yA_391Yd-YV',
    authOptions: FlutterAuthClientOptions(
      localStorage: secureStorage,
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => SupabaseProvider(Supabase.instance.client),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final supabase = context.watch<SupabaseProvider>().client;
    final user = supabase.auth.currentUser;

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: user != null ? const MyHomePage(title: 'Jobb Notater') : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/notes': (context) => const MyHomePage(title: 'Jobb Notater'),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> notes = [];
  int _currentPage = 0; 
  final int pageSize = 5;
  bool _isLoading = false; 
  bool _hasMore = true; 
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes({bool loadMore = false}) async {
    final supabase = context.read<SupabaseProvider>().client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated. Please log in again.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    if ((loadMore && _isLoadingMore) || (!loadMore && _isLoading)) return; 

    setState(() {
      if (loadMore){
        _isLoadingMore = true; 
      } else {
        _isLoading = true; 
        _currentPage = 0;
        _hasMore = true;  
      }
    });

    try {
      final start = _currentPage * pageSize;
      final end = start + pageSize - 1;

      final List<Map<String, dynamic>> fetchedNotes = await supabase
          .from('notes')
          .select('*')
          .range(start, end)
          .order('updated_at', ascending: false);

      if (mounted) {
        setState(() {
          if (loadMore){
            notes.addAll(fetchedNotes);
          } else {
            notes = fetchedNotes;
          }

          _hasMore = fetchedNotes.length == pageSize;

          if (loadMore && fetchedNotes.isNotEmpty){
            _currentPage++;
          } else if (!loadMore) {
            _currentPage = fetchedNotes.isEmpty ? 0 : 1;
          }
          _isLoading = false; 
          _isLoadingMore = false;
        });
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch notes: $e')),
        );
      }
      setState(() {
        _isLoading = false;
        _isLoadingMore = false; 
      });

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
      setState(() {
        _isLoading = false; 
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final supabase = context.read<SupabaseProvider>().client;
              await supabase.auth.signOut(); 
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully!')),
                );
                  Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),

    body: _isLoading && notes.isEmpty  
    ? const Center(child: CircularProgressIndicator())
    : RefreshIndicator(
        onRefresh: () => _fetchNotes(loadMore: false),
        child: ListView.builder(
          itemCount: notes.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            // "Last mer" knapp
            if (index == notes.length) {
              return _isLoadingMore
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Center(
                      child: TextButton(
                        onPressed: () => _fetchNotes(loadMore: true),
                        child: const Text('Last mer...'),
                      ),
                    );
            }
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      notes[index]['title'] ?? 'No Title',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      notes[index]['text'] ?? 'No Content',
                      maxLines: 2,
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteDetailScreen(note: notes[index]),
                        ),
                      );
                      if (result == true) {
                        _fetchNotes();  
                      }
                    },
                  ),
                  
                  if (notes[index]['image_url'] != null && 
                      notes[index]['image_url'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          notes[index]['image_url'],
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: () async  {
          final newNote = await Navigator.push(context, MaterialPageRoute(
            builder: (context) => const NoteAddScreen(),
          ));
          if (newNote == true) {
            _fetchNotes();
          }
        },
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}
