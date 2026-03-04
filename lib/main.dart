import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/note.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized before Hive
  await Hive.initFlutter(); // Initialize Hive with Flutter support
  Hive.registerAdapter(NoteAdapter());// Register the Note adapter
  await Hive.openBox<Note>('notes');// Open the Hive box for storing notes
  runApp(const NotesApp());// Run the main app widget
}

class NotesApp extends StatelessWidget {  // Main app widget, a stateless widget that builds the MaterialApp with theme and home screen
  const NotesApp({super.key});

  @override 
  Widget build(BuildContext context) { // Build the main MaterialApp widget with theme and home screen
    return MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto', // Set the default font family
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomeScreen(),
    );
  }
}