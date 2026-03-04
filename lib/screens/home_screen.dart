import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import '../utils/colors.dart';
import '../widgets/note_card.dart';
import 'add_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = 'All';
  String _viewMode = 'grid';
  String _searchQuery = '';
  List<String> filters = ['All', 'Important', 'To-do lists', 'Shopping list'];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key for controlling the Scaffold (e.g., opening the drawer)
  final TextEditingController _searchController = TextEditingController(); // Controller for managing the search input field

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showViewPicker() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              top: 60,
              right: 12,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                elevation: 8,
                shadowColor: Colors.black26,
                child: SizedBox(
                  width: 180,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ViewOption(
                        icon: Icons.grid_view,
                        label: 'Grid View',
                        isSelected: _viewMode == 'grid',
                        onTap: () {
                          setState(() => _viewMode = 'grid');
                          Navigator.pop(context);
                        },
                      ),
                      Divider(height: 1, color: Colors.grey[200]),
                      _ViewOption(
                        icon: Icons.view_agenda_outlined,
                        label: 'Card View',
                        isSelected: _viewMode == 'card',
                        onTap: () {
                          setState(() => _viewMode = 'card');
                          Navigator.pop(context);
                        },
                      ),
                      Divider(height: 1, color: Colors.grey[200]),
                      _ViewOption(
                        icon: Icons.format_list_bulleted,
                        label: 'List View',
                        isSelected: _viewMode == 'list',
                        onTap: () {
                          setState(() => _viewMode = 'list');
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateCategory() { // Function to display a dialog for creating a new category
    showDialog(
      context: context,
      builder: (_) {
        final controller = TextEditingController();
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create a Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Category Name',
                    hintStyle: const TextStyle(color: Colors.black38),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        setState(() => filters.add(controller.text.trim()));
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5BB8F5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text('Create', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,

      drawer: Drawer( // Navigation drawer for filtering notes by category, with a header and a list of categories that can be selected to filter the displayed notes
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: ValueListenableBuilder(
            valueListenable: Hive.box<Note>('notes').listenable(),
            builder: (context, Box<Note> box, _) {
              final allCount = box.values.length;
              final lockedCount = box.values.where((n) => n.category == 'locked').length;
              final deletedCount = box.values.where((n) => n.category == 'deleted').length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _showCreateCategory();
                          },
                          child: const Text('New', style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.grey[200], height: 1),
                  const SizedBox(height: 8),
                  _DrawerItem(icon: Icons.folder_outlined, label: 'All', count: allCount, isSelected: selectedFilter == 'All', onTap: () { setState(() => selectedFilter = 'All'); Navigator.pop(context); }),
                  _DrawerItem(icon: Icons.lock_outlined, label: 'Locked', count: lockedCount, isSelected: selectedFilter == 'Locked', onTap: () { setState(() => selectedFilter = 'Locked'); Navigator.pop(context); }),
                  _DrawerItem(icon: Icons.delete_outline, label: 'Recently Deleted', count: deletedCount, isSelected: selectedFilter == 'Recently Deleted', onTap: () { setState(() => selectedFilter = 'Recently Deleted'); Navigator.pop(context); }),
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey[200], height: 1),
                ],
              );
            },
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    child: const Icon(Icons.tune, size: 22),
                  ),
                  const Text('Notes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: _showViewPicker,
                    child: Icon(
                      _viewMode == 'grid' ? Icons.grid_view : _viewMode == 'card' ? Icons.view_agenda_outlined : Icons.format_list_bulleted,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // Search bar fonctionnelle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                        decoration: const InputDecoration(
                          hintText: 'Search for notes',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.close, color: Colors.grey, size: 18),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            ValueListenableBuilder(
              valueListenable: Hive.box<Note>('notes').listenable(),
              builder: (context, Box<Note> box, _) {
                final totalCount = box.values.length;
                return SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: filters.map((f) {
                      final isSelected = selectedFilter == f;
                      return GestureDetector(
                        onTap: () => setState(() => selectedFilter = f),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Text(f, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w500, fontSize: 13)),
                              if (f == 'All') ...[
                                const SizedBox(width: 4),
                                Text('$totalCount', style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12)),
                              ]
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<Note>('notes').listenable(),
                builder: (context, Box<Note> box, _) {
                  var notes = box.values.toList();

                  // Filtre par catégorie
                  if (selectedFilter == 'Important') {
                    notes = notes.where((n) => n.category == 'important').toList();
                  } else if (selectedFilter == 'To-do lists') {
                    notes = notes.where((n) => n.category == 'todo').toList();
                  } else if (selectedFilter == 'Shopping list') {
                    notes = notes.where((n) => n.category == 'shopping').toList();
                  } else if (selectedFilter == 'Locked') {
                    notes = notes.where((n) => n.category == 'locked').toList();
                  } else if (selectedFilter == 'Recently Deleted') {
                    notes = notes.where((n) => n.category == 'deleted').toList();
                  } else if (selectedFilter != 'All') {
                    notes = notes.where((n) => n.category == selectedFilter.toLowerCase()).toList();
                  }

                  // Filtre par recherche
                  if (_searchQuery.isNotEmpty) {
                    notes = notes.where((n) =>
                      n.title.toLowerCase().contains(_searchQuery) ||
                      n.content.toLowerCase().contains(_searchQuery)
                    ).toList();
                  }

                  if (notes.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isNotEmpty ? 'No results for "$_searchQuery"' : 'No notes in "$selectedFilter"',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  if (_viewMode == 'grid') return Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: MasonryGrid(notes: notes));
                  if (_viewMode == 'card') return CardViewList(notes: notes);
                  return ListViewNotes(notes: notes);
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddNoteScreen())),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ViewOption extends StatelessWidget { // Widget for displaying an option in the view picker dialog with an icon, label, and selection state
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewOption({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.blue : Colors.black87),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(fontSize: 15, color: isSelected ? Colors.blue : Colors.black87, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget { // Widget for displaying an item in the navigation drawer with an icon, label, count, and selection state
  final IconData icon;
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({required this.icon, required this.label, required this.count, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Icon(icon, size: 22, color: isSelected ? Colors.blue : Colors.black87),
      title: Text(label, style: TextStyle(fontSize: 15, color: isSelected ? Colors.blue : Colors.black87, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
      trailing: Text('$count', style: TextStyle(fontSize: 15, color: isSelected ? Colors.blue : Colors.black54)),
    );
  }
}

class MasonryGrid extends StatelessWidget { // Stateless widget for displaying notes in a masonry grid layout, where notes are distributed into two columns based on their index (even index in the left column, odd index in the right column)
  final List<Note> notes;
  const MasonryGrid({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    final left = <Note>[];
    final right = <Note>[];
    for (int i = 0; i < notes.length; i++) {
      i % 2 == 0 ? left.add(notes[i]) : right.add(notes[i]);
    }
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(children: left.map((n) => NoteCard(note: n)).toList())),
          const SizedBox(width: 8),
          Expanded(child: Column(children: right.map((n) => NoteCard(note: n)).toList())),
        ],
      ),
    );
  }
}

class CardViewList extends StatelessWidget { // Stateless widget for displaying notes in a card view list format, where each note is displayed as a NoteCard widget in a vertical list
  final List<Note> notes;
  const CardViewList({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: notes.length,
      itemBuilder: (_, i) => NoteCard(note: notes[i]),
    );
  }
}

class ListViewNotes extends StatelessWidget { // Stateless widget for displaying notes in a list view format, where each note is displayed as a ListTile with a colored leading bar, title, subtitle, and tap/long press interactions for editing and deleting the note
  final List<Note> notes;
  const ListViewNotes({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: notes.length,
      separatorBuilder: (_, __) => Divider(color: Colors.grey[200], height: 1),
      itemBuilder: (_, i) {
        final note = notes[i];
        final color = noteColors[note.colorIndex % noteColors.length];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
          leading: Container(
            width: 10,
            height: 40,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          ),
          title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(note.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddNoteScreen(existingNote: note))),
          onLongPress: () {
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
                      const Text('Are your sure you want to delete this Note ?', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.black87)),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5BB8F5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 14)),
                              child: const Text('No, Keep', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () { note.category = 'deleted'; note.save(); Navigator.pop(context); },
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF5350), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 14)),
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
          },
        );
      },
    );
  }
}