// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

void main() => runApp(const TodoApp());

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'my Todo App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<TodoItem> todos = [];
  double fontSize = 22.0;

  @override
  void initState() {
    super.initState();
    _loadTodos();
    _loadFontSize();
  }

  void _loadTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? todosString = prefs.getString('todos');
    if (todosString != null) {
      List<dynamic> jsonList = jsonDecode(todosString);
      setState(() {
        todos = jsonList.map((json) => TodoItem.fromJson(jsonDecode(json))).toList();
      });
    }
  }

  void _saveTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList = todos.map((todo) => jsonEncode(todo.toJson())).toList();
    await prefs.setString('todos', jsonEncode(jsonList));
  }

  void _addTodo() async {
    final newTodo = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddTodoScreen(fontSize: fontSize)),
    );
    if (newTodo != null) {
      setState(() {
        todos.add(newTodo);
      });
      _saveTodos();
    }
  }

  void _increaseFontSize() {
    setState(() {
      fontSize += 2;
    });
    _saveFontSize();
  }

  void _decreaseFontSize() {
    setState(() {
      if (fontSize > 10) {
        fontSize -= 2;
      }
    });
    _saveFontSize();
  }

  void _loadFontSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fontSize = prefs.getDouble('fontSize') ?? 16.0;
    });
  }

  void _saveFontSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', fontSize);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addTodo,
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: _increaseFontSize,
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: _decreaseFontSize,
          ),
        ],
      ),
      body: todos.isEmpty
          ? Center(
              child: Text(
                '할 일이 없습니다. 추가해주세요!',
                style: TextStyle(fontSize: fontSize),
              ),
            )
          : ReorderableListView.builder(
              buildDefaultDragHandles: false,
              itemCount: todos.length * 2 - 1,
              onReorder: (oldIndex, newIndex) {
                final actualOldIndex = oldIndex ~/ 2;
                var actualNewIndex = newIndex ~/ 2;

                if (newIndex.isOdd) {
                  actualNewIndex = (newIndex + 1) ~/ 2;
                }

                setState(() {
                  final item = todos.removeAt(actualOldIndex);
                  if (actualNewIndex > actualOldIndex) {
                    actualNewIndex -= 1;
                  }
                  todos.insert(actualNewIndex, item);
                });
                _saveTodos();
              },
              itemBuilder: (context, index) {
                if (index.isOdd) {
                  return Divider(
                    key: Key('divider_$index'),
                    height: 1,
                  );
                }

                final todoIndex = index ~/ 2;
                final todo = todos[todoIndex];

                return ReorderableDragStartListener(
                  index: index,
                  key: Key('$index'),
                  child: ListTile(
                    title: Text(
                      todo.title,
                      style: TextStyle(fontSize: fontSize),
                    ),
                    leading: todo.imagePath != null
                        ? Image.file(
                            File(todo.imagePath!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : null,
                    onTap: () async {
                      final updatedTodo = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddTodoScreen(
                              existingTodo: todo, fontSize: fontSize),
                        ),
                      );
                      if (updatedTodo != null) {
                        setState(() {
                          todos[todoIndex] = updatedTodo;
                        });
                        _saveTodos();
                      }
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          todos.removeAt(todoIndex);
                        });
                        _saveTodos();
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddTodoScreen extends StatefulWidget {
  final TodoItem? existingTodo;
  final double fontSize;

  const AddTodoScreen({
    super.key,
    this.existingTodo,
    required this.fontSize,
  });

  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final TextEditingController _controller = TextEditingController();
  String? imagePath;
  late double fontSize;

  @override
  void initState() {
    super.initState();
    fontSize = widget.fontSize;
    if (widget.existingTodo != null) {
      _controller.text = widget.existingTodo!.title;
      imagePath = widget.existingTodo!.imagePath;
    }
  }

  void _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  void _increaseFontSize() {
    setState(() {
      fontSize += 2;
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (fontSize > 10) {
        fontSize -= 2;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTodo == null ? "Add Todo" : "Edit Todo"),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: _increaseFontSize,
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: _decreaseFontSize,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: "Title"),
              style: TextStyle(fontSize: fontSize),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Attach Image"),
            ),
            if (imagePath != null)
              Image.file(File(imagePath!), height: 100, width: 100, fit: BoxFit.cover),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  TodoItem(title: _controller.text, imagePath: imagePath),
                );
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}

class TodoItem {
  final String title;
  final String? imagePath;

  TodoItem({required this.title, this.imagePath});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'imagePath': imagePath,
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      title: json['title'],
      imagePath: json['imagePath'],
    );
  }
}
