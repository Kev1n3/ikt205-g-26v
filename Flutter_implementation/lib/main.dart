import 'package:flutter/material.dart';
import 'note_detail_screen.dart';
import 'note_add_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.green),
      ),
      home: const MyHomePage(title: 'Assignment 1'),
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
  List<Map<String, String>> notes = [
    {'title': 'Note 1', 'content': 'This is the first note.'},
    {'title': 'Note 2', 'content': 'This is the second note.'},
    {'title': 'Note 3', 'content': 'This is the third note.'},
  ];
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(notes[index]['title']!,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onTap: (){
            Navigator.push(context, MaterialPageRoute
            (builder: (context) => NoteDetailScreen(note: notes[index])));
          },
          subtitle: Text(notes[index]['content']!),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async  {
          final newNote = await Navigator.push(context, MaterialPageRoute(
            builder: (context) => const NoteAddScreen(),
          ));
          if (newNote != null) {
            setState(() {
              notes.add({'title': newNote['title'], 'content': newNote['content']});
            });
          }
        },
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}
