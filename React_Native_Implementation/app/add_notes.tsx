import { useRouter } from 'expo-router';
import { useState } from 'react';
import { StyleSheet, Text, TextInput, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

export default function AddNoteScreen() {
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const router = useRouter();

  const handleSaveNote = () => {
    if (title.trim() === '' || content.trim() === '') {
      alert('Please enter both title and content for the note.');
      return;
    };

    const newNote = {
        id: Date.now().toString(),
        title: title,
        content: content,
    };

    router.push({
        pathname: '/',
        params: { newNote: JSON.stringify(newNote) 
        },
    });
    };


  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.label}>Title:</Text>
      <TextInput
        style={styles.input}
        value={title}
        onChangeText={setTitle}
        placeholder="Enter note title"
      />
      
      <Text style={styles.label}>Content:</Text>
      <TextInput
        style={[styles.input, styles.contentInput]}
        value={content}
        onChangeText={setContent}
        placeholder="Enter note content"
        multiline
      />
      
      <TouchableOpacity style={styles.saveButton} onPress={handleSaveNote}>
        <Text style={styles.saveButtonText}>Save Note</Text>
      </TouchableOpacity>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {  // NY: Container for hele skjermen
    flex: 1,           // Tar opp all tilgjengelig plass
    padding: 20,       // Luft rundt kantene
    backgroundColor: '#fff',
  },
  label: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  input: {
    borderWidth: 1,
    borderColor: '#ccc',
    borderRadius: 8,
    padding: 12,
    marginBottom: 20,
    fontSize: 16,
  },
  contentInput: {
    height: 120,
    textAlignVertical: 'top',
  },
  saveButton: {
    backgroundColor: '#007BFF',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 10,
  },
  saveButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
});