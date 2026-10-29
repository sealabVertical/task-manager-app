import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';

class TaskRepository {
  static Database? _database;

  // Open the database or reuse the existing connection.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database and create the tasks table.
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            isCompleted INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  // Retrieve all tasks.
  Future<List<Task>> getAllTasks() async {
    final db = await database;

    final List<Map<String, Object?>> maps = await db.query(
      'tasks',
      orderBy: 'id DESC',
    );

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // Insert a new task.
  Future<int> addTask(String title) async {
    final db = await database;

    return await db.insert('tasks', {'title': title, 'isCompleted': 0});
  }

  // Update a task's completion status.
  Future<int> updateTaskStatus(int id, bool isCompleted) async {
    final db = await database;

    return await db.update(
      'tasks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a task.
  Future<int> deleteTask(int id) async {
    final db = await database;

    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
