import { StyleSheet } from 'react-native';

import { Image } from 'expo-image';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useEffect, useState } from 'react';
import { FlatList, Text, TouchableOpacity, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';


export default function HomeScreen() {
  const params = useLocalSearchParams();
  const router = useRouter();
  const [notes, setNotes] = useState([
    { id: '1', title: 'Note 1', content: 'This is the first note.' },
    { id: '2', title: 'Note 2', content: 'This is the second note.' },
    { id: '3', title: 'Note 3', content: 'This is the third note.' },
  ]);

  useEffect(() => {
    if (params.newNote) {
      try {
        const newNote = JSON.parse(params.newNote as string);
        setNotes((prevNotes) => [...prevNotes, newNote]);
        router.setParams({ newNote: undefined });
      }catch (error) {
        console.error('Error parsing new note:', error);
      }
    }
  }, [params.newNote]);
  
  const navigateToAddNote = () => {
    router.push('/add_notes');
  };

  return (
    <SafeAreaView style={styles.container }>
      <View style={styles.header}>
        <Image
          source={require('@/assets/images/partial-react-logo.png')}
          style={styles.headerImage}
        />
      </View>

      <View style={styles.stepContainer}>
        <Text style={styles.subtitle}>My Notes:</Text>

        <FlatList
          data={notes}
          keyExtractor={(item) => item.id}
          renderItem={({ item }) => (
            <TouchableOpacity
              onPress={() => router.push({
                pathname: '/details_notes',
                params: { note: JSON.stringify(item) },
              })}
              >
              <View style={{ padding: 10, backgroundColor: '#eee', marginBottom: 5 }}>
                <Text style={{ fontWeight: 'bold' }}>{item.title}</Text>
                <Text>{item.content}</Text>
              </View>
            </TouchableOpacity>
          )}
        />
      </View>
      <TouchableOpacity style={styles.fab} onPress={navigateToAddNote}>
      <Text style={styles.fabText}>+</Text>
    </TouchableOpacity>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  titleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  container: {  
    flex: 1,
    backgroundColor: '#fff',
  },
  header: {
  width: '100%',
  height: 200,  // Fast høyde på header-området
  position: 'relative',  // For å kunne plassere tekst oppå bildet
  justifyContent: 'center',
  alignItems: 'center',
  },
  headerImage: {
    position: 'absolute',  // Legger bildet som bakgrunn
    width: '100%',
    height: '100%',
    resizeMode: 'cover',  // Dekker hele header-området
    top: 0,
    left: 0,
  },
  subtitle: {
    fontSize: 18,
    fontWeight: 'bold',
  },
  stepContainer: {
    gap: 8,
    marginBottom: 8,
  },
  fab: {
    position: 'absolute',
    bottom: 20,
    right: 20,
    backgroundColor: '#007BFF',
    width: 60,
    height: 60,
    borderRadius: 30,
    justifyContent: 'center',
    alignItems: 'center',
    elevation: 5,
  },
  fabText: {
    color: '#fff',
    fontSize: 24,
    fontWeight: 'bold',
  },
});
