import 'package:flutter/material.dart';

class NoteAddScreen extends StatefulWidget {
  const NoteAddScreen({super.key});
  @override
  State<NoteAddScreen> createState() => _NoteAddScreenState();
}

class _NoteAddScreenState extends State<NoteAddScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle saving the note here
                String title = _titleController.text;
                String content = _contentController.text;
                print('Saving note: $title - $content');
                Navigator.pop(context, {'title': title, 'content': content});
              },
              child: const Text('Save Note'),
            ),
          ],
        ),
      ),
    );
  }
}