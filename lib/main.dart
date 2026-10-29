import 'package:flutter/material.dart';

import 'models/task.dart';
import 'repositories/task_repository.dart';

void main() {
  runApp(const TaskManagementApp());
}

class TaskManagementApp extends StatelessWidget {
  const TaskManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TaskHomePage(),
    );
  }
}

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key});

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  final TaskRepository _repository = TaskRepository();
  final TextEditingController _taskController = TextEditingController();

  List<Task> _tasks = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Load saved tasks from SQLite.
  Future<void> _loadTasks() async {
    try {
      final tasks = await _repository.getAllTasks();

      if (!mounted) return;

      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Failed to load tasks.');
    }
  }

  // Add a new task after validating the title.
  Future<void> _addTask() async {
    final title = _taskController.text.trim();

    if (title.isEmpty) {
      _showMessage('Please enter a task title.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _repository.addTask(title);

      if (!mounted) return;

      _taskController.clear();

      await _loadTasks();

      if (!mounted) return;

      _showMessage('Task added successfully.');
    } catch (e) {
      if (!mounted) return;

      _showMessage('Failed to add task.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // Change a task's completion status.
  Future<void> _toggleTask(Task task, bool? value) async {
    if (task.id == null || value == null) return;

    try {
      await _repository.updateTaskStatus(task.id!, value);
      await _loadTasks();
    } catch (e) {
      if (!mounted) return;

      _showMessage('Failed to update task.');
    }
  }

  // Delete a task from SQLite.
  Future<void> _deleteTask(Task task) async {
    if (task.id == null) return;

    try {
      await _repository.deleteTask(task.id!);
      await _loadTasks();

      if (!mounted) return;

      _showMessage('Task deleted successfully.');
    } catch (e) {
      if (!mounted) return;

      _showMessage('Failed to delete task.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _tasks.where((task) => task.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stay organized!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                '$completedCount of ${_tasks.length} tasks completed',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              // Task input and Add button.
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _taskController,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addTask(),
                      decoration: InputDecoration(
                        hintText: 'Enter a task...',
                        prefixIcon: const Icon(Icons.edit_note),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed: _isSaving ? null : _addTask,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Task List',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.task_alt,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No tasks yet.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add a task to get started.',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: Checkbox(
                                value: task.isCompleted,
                                onChanged: (value) => _toggleTask(task, value),
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: task.isCompleted ? Colors.grey : null,
                                ),
                              ),
                              subtitle: Text(
                                task.isCompleted ? 'Completed' : 'Pending',
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                tooltip: 'Delete task',
                                onPressed: () => _deleteTask(task),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
