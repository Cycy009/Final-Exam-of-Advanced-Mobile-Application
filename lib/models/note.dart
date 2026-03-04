import 'package:hive/hive.dart'; // Import Hive for data persistence

part 'note.g.dart'; // Part directive for generated code (Hive adapter)

//note.dart defines the Note model — it's the blueprint for every note stored in Hive.It describes what a note is made of:

@HiveType(typeId: 0) 
class Note extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late String content;

  @HiveField(2)
  late String category; // 'important', 'todo', 'shopping', 'other'

  @HiveField(3)
  late int colorIndex;

  @HiveField(4)
  late DateTime createdAt;
}