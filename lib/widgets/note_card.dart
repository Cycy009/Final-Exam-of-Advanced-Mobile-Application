import 'package:flutter/material.dart';
import '../models/note.dart';
import '../screens/add_note_screen.dart';
import '../utils/colors.dart';

class NoteCard extends StatelessWidget { // Stateless widget for displaying a note in a card format, with tap and long press interactions for editing and deleting the note
  final Note note;
  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final color = noteColors[note.colorIndex % noteColors.length];

    return GestureDetector( // Detect tap and long press gestures on the note card
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddNoteScreen(existingNote: note)),
      ),
      onLongPress: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete note?'),
            content: const Text('This note will be moved to Recently Deleted.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  note.category = 'deleted';
                  note.save();
                  Navigator.pop(context);
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Container( // Container for styling the note card with margin, padding, background color, and rounded corners
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                if (note.category == 'locked')
                  const Icon(Icons.lock, size: 14, color: Colors.blueGrey),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note.content,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}