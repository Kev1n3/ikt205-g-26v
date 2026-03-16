import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NoteAddScreen extends StatefulWidget {
  final Map<String, dynamic>? note;

  const NoteAddScreen({super.key, this.note});

  @override
  State<NoteAddScreen> createState() => _NoteAddScreenState();
}

class _NoteAddScreenState extends State<NoteAddScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!['title'] ?? '';
      _contentController.text = widget.note!['text'] ?? '';
    }
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title or Content cannot be empty.')),
      );
      return;
    }

    setState(()=> _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated. Please log in again.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      if (widget.note != null) {
        await Supabase.instance.client.from('notes').update({
          'title': title,
          'text': content,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', widget.note!['id']);
      } else {
        await Supabase.instance.client.from('notes').insert({
          'user_id': user.id,
          'title': title,
          'text': content,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(widget.note != null ? 'Note updated successfully!' : 'Note created successfully!')),
        );
        Navigator.pop(context, true);
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: $e')),
        );
      }
    } catch (e) {
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    }
    setState(()=> _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'Add Note'),
      ), 
      body: SingleChildScrollView(  
        child: Padding(
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
                onPressed: _isLoading ? null : _saveNote, style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : Text(isEditing ? 'Update Note' : 'Create Note'),
                ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: true, 
    );
  }
}