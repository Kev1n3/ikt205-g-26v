import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'services/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart'; 
import 'main.dart';

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

  File? _selectedImage;
  String? _imageUrl;
  final ImagePickerService _imagePickerService = ImagePickerService();
  final Uuid _uuid = const Uuid();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();  

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!['title'] ?? '';
      _contentController.text = widget.note!['text'] ?? '';
      _imageUrl = widget.note!['image_url'];
    }
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await _localNotificationsPlugin.initialize(initializationSettings);

    await _localNotificationsPlugin.resolvePlatformSpecificImplementation
    <AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  Future<void> _pickFromGallery() async {
    PermissionStatus status = await Permission.photos.request();
    if (status.isGranted){
        try {
        final pickedFile = await _imagePickerService.pickImageFromGallery();
        if (pickedFile != null) {
          _imagePickerService.validateImage(pickedFile);
          setState(() => _selectedImage = pickedFile);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error picking image from gallery: $e')),
          );
        }
      }
    } else {
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Galleritilgang er påkrevd for å velge bilde'))
        );
      }
    }
  }

  Future<void> _pickFromCamera() async {
    PermissionStatus status = await Permission.camera.request();

    if (status.isGranted){
      try {
        final pickedFile = await _imagePickerService.pickImageFromCamera();
        if (pickedFile != null) {
          _imagePickerService.validateImage(pickedFile);
          setState(() => _selectedImage = pickedFile);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error taking photo: $e')),
          );
        }
      }
    } else {
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kameraitilgang er påkrevd for å ta bildet'))
        );
      }
    }
  }

  Future<String> _uploadImage(File file) async {
    try {
      final supabase = context.read<SupabaseProvider>().client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Ikke innlogget');

      if (!file.existsSync()) throw Exception('Filen finnes ikke');

      final ext = file.path.split('.').last;
      final fileName = '${_uuid.v4()}.$ext';
      final filePath = 'notes/$fileName';

      // Upload
      await supabase.storage
          .from('images')
          .upload(filePath, file);

      // Hent URL
      return supabase.storage
          .from('images')
          .getPublicUrl(filePath);
          
    } catch (e) {
      throw Exception('Kunne ikke laste opp bildet');
    }
  }

  Future<void> _showNotification(String noteTitle) async {
      const androidDetails = AndroidNotificationDetails(
        'notes_channel',
        'Notater',
        importance: Importance.high,
        priority: Priority.high,
      );
      const details = NotificationDetails(android: androidDetails);

      await _localNotificationsPlugin.show(
        0,
        'Nytt notat',
        'Nytt notat: $noteTitle',
        details,
      );
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
      final supabase = context.read<SupabaseProvider>().client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated. Please log in again.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      String? finalImageUrl = _imageUrl;
      if (_selectedImage != null) {
        finalImageUrl = await _uploadImage(_selectedImage!);
      }

      if (widget.note != null) {
        await supabase.from('notes').update({
          'title': title,
          'text': content,
          'image_url': finalImageUrl,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', widget.note!['id']);
      } else {
        await supabase.from('notes').insert({
          'user_id': user.id,
          'title': title,
          'text': content,
          'image_url': finalImageUrl,
        });
        await _showNotification(title);
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

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickFromGallery, 
                      icon: const Icon(Icons.photo_library), 
                      label: const Text('Gallery'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickFromCamera, 
                      icon: const Icon(Icons.camera_alt), 
                      label: const Text('Camera'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_selectedImage != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_selectedImage!, height: 150, fit: BoxFit.cover),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _selectedImage = null;
                    _imageUrl = null;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Image removed')),
                    );
                  }),
                  child: const Text('Remove Image', style: TextStyle(color: Colors.red)),
                ),
              ] else if (_imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(_imageUrl!, height: 150, fit: BoxFit.cover),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _selectedImage = null;
                    _imageUrl = null;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Image removed')),
                    );
                  }),
                  child: const Text('Remove Image', style: TextStyle(color: Colors.red)),
                ),
              ],

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