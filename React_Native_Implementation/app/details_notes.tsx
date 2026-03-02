import { useLocalSearchParams, useRouter } from 'expo-router';
import { StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

export default function DetailsNotesScreen() {
  const params = useLocalSearchParams();
  const router = useRouter();
  
  const note = params.note ? JSON.parse(params.note as string) : null;

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        {note ? (
          <>
            <Text style={styles.title}>{note.title}</Text>
            <Text style={styles.contentText}>{note.content}</Text>
          </>
        ) : (
          <Text style={styles.error}>Ingen notat funnet</Text>
        )}
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  content: {
    padding: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 20,
  },
  contentText: {
    fontSize: 16,
    lineHeight: 24,
  },
  error: {
    fontSize: 16,
    color: 'red',
    textAlign: 'center',
  },
});