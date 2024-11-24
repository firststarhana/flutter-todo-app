import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_screen.dart';
import 'localization.dart';  // Localization 파일 추가
import 'dart:convert';      // JSON 처리를 위해 추가
import 'dart:io';           // 파일 처리를 위해 추가
import 'package:image_picker/image_picker.dart';  // 이미지 선택을 위해 추가

void main() => runApp(TodoApp());

class TodoApp extends StatefulWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  String currentLanguage = 'ko'; // 기본 언어
  Color currentThemeColor = Colors.purple[200]!; // 기본 테마 색상

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentLanguage = prefs.getString('language') ?? 'ko';
      int? colorValue = prefs.getInt('themeColor');
      if (colorValue != null) {
        currentThemeColor = Color(colorValue);
      }
    });
  }

  void _updateLanguage(String newLanguage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLanguage);
    setState(() {
      currentLanguage = newLanguage;
    });
  }

  void _updateThemeColor(Color newColor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeColor', newColor.value);
    setState(() {
      currentThemeColor = newColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppLocalizations.getText('appTitle', currentLanguage),
      theme: ThemeData(
  primaryColor: currentThemeColor, // AppBar 및 주요 색상
  appBarTheme: AppBarTheme(
    color: currentThemeColor, // AppBar 색상
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: currentThemeColor, // FloatingActionButton 색상
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: currentThemeColor, // ElevatedButton의 배경색
    ),
  ),
  scaffoldBackgroundColor: Colors.white, // 앱의 배경색을 흰색으로 유지
),

      home: TodoListScreen(
        currentLanguage: currentLanguage,
        onLanguageChange: _updateLanguage,
        onThemeChange: _updateThemeColor,
      ),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  final String currentLanguage;
  final ValueChanged<String> onLanguageChange;
  final ValueChanged<Color> onThemeChange;

  const TodoListScreen({
    Key? key,
    required this.currentLanguage,
    required this.onLanguageChange,
    required this.onThemeChange,
  }) : super(key: key);

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<TodoItem> todos = [];
  double fontSize = 18.0;

  @override
  void initState() {
    super.initState();
    _loadTodos();
    _loadFontSize();
  }

  @override
  void didUpdateWidget(TodoListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLanguage != widget.currentLanguage) {
      setState(() {
        // 화면 재빌드
      });
    }
  }

  void _loadTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? todosString = prefs.getString('todos');
    if (todosString != null) {
      List<dynamic> jsonList = jsonDecode(todosString);
      setState(() {
        todos = jsonList
            .map((json) => TodoItem.fromJson(jsonDecode(json)))
            .toList();
      });
    }
  }

  void _saveTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList =
        todos.map((todo) => jsonEncode(todo.toJson())).toList();
    await prefs.setString('todos', jsonEncode(jsonList));
  }

  void _addTodo() async {
    final newTodo = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTodoScreen(
          fontSize: fontSize,
          currentLanguage: widget.currentLanguage, // 언어 전달
        ),
      ),
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

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          currentLanguage: widget.currentLanguage,
          onLanguageChange: widget.onLanguageChange,
          onThemeChange: widget.onThemeChange,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String currentLanguage = widget.currentLanguage;

    String emptyTodoMessage =
        AppLocalizations.getText('emptyTodoMessage', currentLanguage);
    String appTitle =
        AppLocalizations.getText('appTitle', currentLanguage);
    String addTodoTooltip =
        AppLocalizations.getText('addTodo', currentLanguage);
    String increaseFontTooltip =
        AppLocalizations.getText('increaseFont', currentLanguage);
    String decreaseFontTooltip =
        AppLocalizations.getText('decreaseFont', currentLanguage);
    String settingsTooltip =
        AppLocalizations.getText('settings', currentLanguage);
    String deleteTooltip =
        AppLocalizations.getText('delete', currentLanguage);

    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addTodo,
            tooltip: addTodoTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: _increaseFontSize,
            tooltip: increaseFontTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: _decreaseFontSize,
            tooltip: decreaseFontTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _openSettings(context),
            tooltip: settingsTooltip,
          ),
        ],
      ),
      body: todos.isEmpty
          ? Center(
              child: Text(
                emptyTodoMessage,
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16.0),
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
                            existingTodo: todo,
                            fontSize: fontSize,
                            currentLanguage: currentLanguage,
                          ),
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
                      tooltip: deleteTooltip,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: const Icon(Icons.add),
        tooltip: addTodoTooltip,
      ),
    );
  }
}

class AddTodoScreen extends StatefulWidget {
  final TodoItem? existingTodo;
  final double fontSize;
  final String currentLanguage;

  const AddTodoScreen({
    Key? key,
    this.existingTodo,
    required this.fontSize,
    required this.currentLanguage,
  }) : super(key: key);

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
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
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
    String currentLanguage = widget.currentLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTodo == null
            ? AppLocalizations.getText('addTodo', currentLanguage)
            : AppLocalizations.getText('editTodo', currentLanguage)),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: _increaseFontSize,
            tooltip:
                AppLocalizations.getText('increaseFont', currentLanguage),
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: _decreaseFontSize,
            tooltip:
                AppLocalizations.getText('decreaseFont', currentLanguage),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                  labelText:
                      AppLocalizations.getText('title', currentLanguage)),
              style: TextStyle(fontSize: fontSize),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              showCursor: true,
              cursorWidth: 2.0,
              cursorColor: Theme.of(context).primaryColor,
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text(AppLocalizations.getText(
                  'attachImage', currentLanguage)),
            ),
            if (imagePath != null)
              Image.file(File(imagePath!),
                  height: 100, width: 100, fit: BoxFit.cover),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  TodoItem(title: _controller.text, imagePath: imagePath),
                );
              },
              child: Text(
                  AppLocalizations.getText('save', currentLanguage)),
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
