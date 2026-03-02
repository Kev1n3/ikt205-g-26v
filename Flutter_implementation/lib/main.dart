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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.green),
      ),
      home: const MyHomePage(title: 'Assignment 1'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
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
