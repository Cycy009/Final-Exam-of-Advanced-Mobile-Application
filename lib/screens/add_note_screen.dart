import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/note.dart';
import '../utils/colors.dart';

class AddNoteScreen extends StatefulWidget { // Stateful widget for adding or editing a note, with optional existing note data
  final Note? existingNote;
  const AddNoteScreen({super.key, this.existingNote});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _category;
  late int _colorIndex;
  bool _isLocked = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingNote?.title ?? '');
    _contentController = TextEditingController(text: widget.existingNote?.content ?? '');
    _category = widget.existingNote?.category ?? 'other';
    _colorIndex = widget.existingNote?.colorIndex ?? 0;
    _isLocked = widget.existingNote?.category == 'locked';

    _titleController.addListener(() => setState(() => _hasChanges = true));
    _contentController.addListener(() => setState(() => _hasChanges = true));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(color: Color(0xFF555555), shape: BoxShape.circle),
                child: const Icon(Icons.info_outline, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 20),
              const Text(
                'Are your sure you want discard your changes ?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5BB8F5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('No, Keep', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF5350),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Yes, Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  void _save() { // Function to save the note, either by updating an existing note or creating a new one, and then navigating back
    if (_titleController.text.trim().isEmpty) return;
    final box = Hive.box<Note>('notes');
    if (widget.existingNote != null) {
      widget.existingNote!
        ..title = _titleController.text.trim()
        ..content = _contentController.text.trim()
        ..category = _isLocked ? 'locked' : _category
        ..colorIndex = _colorIndex
        ..save();
    } else {
      final note = Note()
        ..title = _titleController.text.trim()
        ..content = _contentController.text.trim()
        ..category = _isLocked ? 'locked' : _category
        ..colorIndex = _colorIndex
        ..createdAt = DateTime.now();
      box.add(note);
    }
    setState(() => _hasChanges = false);
    Navigator.pop(context);
  }

  void _showOptionsMenu() { // Function to display a bottom sheet with options for changing the note's background color, setting a reminder, locking/unlocking, moving, or deleting the note
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Background', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: noteColors.length,
                  itemBuilder: (_, i) {
                    final isSelected = _colorIndex == i;
                    return GestureDetector(
                      onTap: () {
                        setState(() { _colorIndex = i; _hasChanges = true; });
                        setModalState(() {});
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: noteColors[i],
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 2.5)
                              : Border.all(color: Colors.grey[300]!, width: 1),
                        ),
                        child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.black54) : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Divider(color: Colors.grey[200]),
              const SizedBox(height: 4),
              _BottomAction(icon: Icons.alarm_outlined, label: 'Reminder', onTap: () { Navigator.pop(context); _showReminder(); }),
              _BottomAction(
                icon: _isLocked ? Icons.lock : Icons.lock_open_outlined,
                label: _isLocked ? 'Unlock' : 'Lock',
                color: _isLocked ? Colors.blue : null,
                onTap: () {
                  setState(() { _isLocked = !_isLocked; _hasChanges = true; });
                  setModalState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_isLocked ? 'Note locked' : 'Note unlocked'), duration: const Duration(seconds: 1)),
                  );
                },
              ),
              _BottomAction(icon: Icons.drive_file_move_outline, label: 'Move Note', onTap: () { Navigator.pop(context); _moveNote(); }),
              _BottomAction(icon: Icons.delete_outline, label: 'Delete', color: Colors.red, onTap: () { Navigator.pop(context); _delete(); }),
            ],
          ),
        ),
      ),
    );
  }

  void _delete() { // Function to show a confirmation dialog for deleting the note, and if confirmed, move the note to the 'deleted' category and navigate back
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(color: Color(0xFF555555), shape: BoxShape.circle),
                child: const Icon(Icons.info_outline, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 20),
              const Text(
                'Are your sure you want to delete this Note ?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5BB8F5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('No, Keep', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.existingNote != null) {
                          widget.existingNote!.category = 'deleted';
                          widget.existingNote!.save();
                        }
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF5350),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Yes, Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReminder() { // Function to display a date picker for setting a reminder, and if a date is selected, show a snackbar with the selected reminder date
    showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((date) {
      if (date != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reminder set for ${date.day}/${date.month}/${date.year}')),
        );
      }
    });
  }

  void _moveNote() { // Function to display a bottom sheet with category options for moving the note, and when a category is selected, update the note's category and show a snackbar confirming the move
    final categories = ['other', 'important', 'todo', 'shopping'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Move to', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...categories.map((c) => ListTile(
              leading: Icon(
                c == 'important' ? Icons.star_outline : c == 'todo' ? Icons.check_box_outline_blank : c == 'shopping' ? Icons.shopping_cart_outlined : Icons.folder_outlined,
              ),
              title: Text(c[0].toUpperCase() + c.substring(1)),
              selected: _category == c,
              selectedColor: Colors.blue,
              onTap: () {
                setState(() { _category = c; _hasChanges = true; });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Moved to $c'), duration: const Duration(seconds: 1)),
                );
              },
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = noteColors[_colorIndex % noteColors.length];

    return WillPopScope( // Intercept back navigation to show a confirmation dialog if there are unsaved changes
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
            onPressed: () async {
              if (await _onWillPop()) Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: Colors.black),
              onPressed: _save,
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onPressed: _showOptionsMenu,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: 'Type something...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 16, color: Colors.black38),
                  ),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  maxLines: null,
                  expands: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget { // Stateless widget for displaying an action in the options menu with an icon, label, and tap callback, and an optional color for the text and icon
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _BottomAction({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.black87;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: c),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(fontSize: 15, color: c)),
          ],
        ),
      ),
    );
  }
}