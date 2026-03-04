## Notes App ##

A Flutter mobile application for creating and managing notes, built with Hive for local storage.

## Features

- Create, edit, and delete notes
- Multiple background colors per note
- Filter notes by category (All, Important, To-do, Shopping, Locked, Recently Deleted)
- Search notes by title or content
- Three view modes: Grid, Card, List
- Lock notes
- Set reminders
- Move notes between categories
- Soft delete (Recently Deleted)

## Project Structure

```
lib/
├── main.dart                  # App entry point, Hive initialization
├── models/
│   ├── note.dart              # Note data model
│   └── note.g.dart            # Auto-generated Hive adapter
├── screens/
│   ├── home_screen.dart       # Main screen with notes list
│   └── add_note_screen.dart   # Create/edit note screen
├── widgets/
│   └── note_card.dart         # Note card widget
└── utils/
    └── colors.dart            # Shared color palette
```

## Tech Stack

- **Flutter** — UI framework
- **Hive** — Local NoSQL database
- **hive_flutter** — Flutter integration for Hive
- **build_runner + hive_generator** — Code generation for Hive adapters

## Getting Started

### Prerequisites
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/notes_app.git
cd notes_app

# Install dependencies
flutter pub get

# Generate Hive adapters
flutter pub run build_runner build

# Run the app
flutter run
```

### Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
```

## How It Works

**Database** — Hive stores notes locally as binary data. Each `Note` object is serialized by the auto-generated `NoteAdapter` in `note.g.dart`.

**Reactivity** — `ValueListenableBuilder` listens to the Hive box and rebuilds the UI automatically whenever a note is added, edited, or deleted.

**State** — Local UI state (selected filter, view mode, search query) is managed with plain `setState` inside each `StatefulWidget`.

## Screens

| Screen | Type | Manages |
|---|---|---|
| `HomeScreen` | Stateful | Filter, view mode, search query |
| `AddNoteScreen` | Stateful | Color, lock state, changes tracking |

## Widgets

| Widget | Type | Role |
|---|---|---|
| `NoteCard` | Stateless | Displays a single note |
| `MasonryGrid` | Stateless | Two-column grid layout |
| `CardViewList` | Stateless | Full-width card layout |
| `ListViewNotes` | Stateless | Compact list layout |
| `_DrawerItem` | Stateless | Single drawer category row |
| `_ViewOption` | Stateless | Single view mode option row |
| `_BottomAction` | Stateless | Single options menu action row |

## Note Model

```dart
@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0) late String title;
  @HiveField(1) late String content;
  @HiveField(2) late String category; // 'other', 'important', 'todo', 'shopping', 'locked', 'deleted'
  @HiveField(3) late int colorIndex;
  @HiveField(4) late DateTime createdAt;
}
```

## Design Decisions

- **Soft delete** — notes are never permanently deleted immediately. Setting `category = 'deleted'` moves them to Recently Deleted.
- **Single color file** — `utils/colors.dart` is the single source of truth for colors, imported by all screens and widgets to avoid conflicts.
- **No Provider** — Hive's built-in `ValueListenableBuilder` handles data reactivity. `setState` handles local UI state. No external state management library needed.
```
