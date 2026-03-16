import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'note_add_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final Map<String, dynamic> note;
  
  const NoteDetailScreen({super.key, required this.note});

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr).toLocal();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Slett notat'),
        content: const Text('Er du sikker på at du vil slette dette notatet?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Avbryt'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); 

              try {
                await Supabase.instance.client.from('notes').delete().eq('id', note['id']);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notat slettet')),
                  );
                  Navigator.pop(context, true);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Feil ved sletting: $e')),
                  );
                }
              }
            },
            child: const Text('Slett', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final created = note['created_at'];
    final updated = note['updated_at'];
    final hasBeenUpdated = updated != null && updated != created;

    final currentUser = Supabase.instance.client.auth.currentUser;
    final isOwner = currentUser != null && note['user_id'] == currentUser.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(note['title'] ?? 'Notat'),
        actions: [
          if (isOwner) ... [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Rediger notat',
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteAddScreen(note: note),
                    ),
                  );
                  if (result == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
              ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Slett notat',
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Bruker
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        note['email'] ?? 'Ukjent bruker',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Dato
                  Row(
                    children: [
                      Icon(
                        hasBeenUpdated ? Icons.update : Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hasBeenUpdated 
                          ? 'Sist endret: ${_formatDateTime(updated)}'
                          : 'Opprettet: ${_formatDateTime(created)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              note['title'] ?? '',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Container(height: 1, color: Colors.grey[300]),
            const SizedBox(height: 16),
            
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  note['text'] ?? '',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}