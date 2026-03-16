import 'package:flutter/material.dart';
import 'note_detail_screen.dart';
import 'note_add_screen.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/secure_storage.dart';

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
  runApp(MyApp());
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
    final user = Supabase.instance.client.auth.currentUser;

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

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated. Please log in again.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    try {
      final List<Map<String, dynamic>> fetchedNotes = await Supabase.instance.client
          .from('notes')
          .select('*')
          .order('updated_at', ascending: false);

      if (mounted) {
        setState(() {
          notes.clear();
          notes.addAll(fetchedNotes);
        });
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch notes: $e')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
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
              await Supabase.instance.client.auth.signOut();
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
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(notes[index]['title']??'No Title',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          subtitle: Text(notes[index]['text']!),
        );
      },
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
