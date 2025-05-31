import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database_service.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TextEditingController _taskController = TextEditingController();
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    DataSnapshot? snapshot = await DatabaseService().read(path: 'tasks');
    if (snapshot?.value != null) {
      setState(() {
        if (snapshot!.value is Map) {
          _tasks =
              (snapshot.value as Map<Object?, Object?>).entries.map((entry) {
                if (entry.value is Map) {
                  final taskData = Map<String, dynamic>.from(
                    entry.value as Map,
                  );
                  taskData['id'] = entry.key.toString();
                  return taskData;
                }
                return <String, dynamic>{};
              }).toList();
        } else {
          _tasks = [];
        }
      });
    }
  }

  Future<void> _addTask() async {
    if (_taskController.text.isEmpty) return;

    final newTask = {
      'title': _taskController.text,
      'completed': false,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await DatabaseService().create(path: 'tasks', data: newTask);

    _taskController.clear();
    await _loadTasks();
  }

  Future<void> _toggleTask(String taskId, bool currentStatus) async {
    await DatabaseService().update(
      path: 'tasks/$taskId',
      data: {'completed': !currentStatus},
    );
    await _loadTasks();
  }

  Future<void> _deleteTask(String taskId) async {
    await DatabaseService().delete(path: 'tasks/$taskId');
    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    hintText: 'Nueva tarea',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(onPressed: _addTask, child: Text('Agregar')),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final task = _tasks[index];
              final createdAt =
                  task['createdAt'] != null
                      ? DateTime.parse(task['createdAt'])
                      : DateTime.now();
              final formattedDate = DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(createdAt);

              return ListTile(
                title: Text(task['title'] ?? 'Sin título'),
                subtitle: Text(formattedDate),
                leading: Checkbox(
                  value: task['completed'] ?? false,
                  onChanged:
                      (value) => _toggleTask(
                        task['id'] ?? '',
                        task['completed'] ?? false,
                      ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteTask(task['id'] ?? ''),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
