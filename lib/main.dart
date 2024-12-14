// localization.dart는 변경 없음

// main.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_screen.dart';
import 'localization.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:async'; // Timer를 사용하기 위해 추가

void main() => runApp(const TodoApp());

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

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
        currentThemeColor: currentThemeColor,
        onLanguageChange: _updateLanguage,
        onThemeChange: _updateThemeColor,
      ),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  final String currentLanguage;
  final Color currentThemeColor;
  final ValueChanged<String> onLanguageChange;
  final ValueChanged<Color> onThemeChange;

  const TodoListScreen({
    super.key,
    required this.currentLanguage,
    required this.currentThemeColor,
    required this.onLanguageChange,
    required this.onThemeChange,
  });

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<TodoItem> todos = [];
  double fontSize = 18.0;
  Timer? _timer; // Timer 추가

  @override
  void initState() {
    super.initState();
    _loadTodos();
    _loadFontSize();
    // 1분마다 화면 갱신
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          // 1분마다 화면 갱신
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // 화면 종료 시 타이머 해제
    super.dispose();
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
          currentLanguage: widget.currentLanguage,
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

  String formatCreatedDate(DateTime date) {
    return DateFormat('yyyy년MM월dd일 HH시mm분ss초').format(date);
  }

  // 경과 시간 포맷 수정: 년, 월, 일, 시, 분 단위로 세분화
  String formatElapsedTime(DateTime start) {
    final now = DateTime.now();
    final difference = now.difference(start);

    if (difference.inSeconds < 60) {
      return "방금전";
    }

    int totalMinutes = difference.inMinutes;

    int years = totalMinutes ~/ (365 * 24 * 60);
    totalMinutes %= (365 * 24 * 60);

    int months = totalMinutes ~/ (30 * 24 * 60);
    totalMinutes %= (30 * 24 * 60);

    int days = totalMinutes ~/ (24 * 60);
    totalMinutes %= (24 * 60);

    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    List<String> parts = [];
    if (years > 0) parts.add("$years년");
    if (months > 0) parts.add("$months개월");
    if (days > 0) parts.add("$days일");
    if (hours > 0) parts.add("$hours시간");
    if (minutes > 0) parts.add("$minutes분");

    return "작성한지 ${parts.join(' ')} 경과";
  }

  @override
  Widget build(BuildContext context) {
    String currentLanguage = widget.currentLanguage;

    String emptyTodoMessage =
        AppLocalizations.getText('emptyTodoMessage', currentLanguage);
    String appTitle = AppLocalizations.getText('appTitle', currentLanguage);
    String addTodoTooltip = AppLocalizations.getText('addTodo', currentLanguage);
    String increaseFontTooltip =
        AppLocalizations.getText('increaseFont', currentLanguage);
    String decreaseFontTooltip =
        AppLocalizations.getText('decreaseFont', currentLanguage);
    String settingsTooltip =
        AppLocalizations.getText('settings', currentLanguage);
    // delete에 대한 번역이 localization에 없으므로 직접 추가 필요. 
    // 여기서는 영어 그대로 사용하거나 '삭제'로 고정
    String deleteTooltip = '삭제';

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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("최초로 작성한 날짜: ${formatCreatedDate(todo.dateCreated)}"),
                        Text(formatElapsedTime(todo.dateCreated)),
                        const SizedBox(height: 4),
                        Text("마지막 수정: ${formatCreatedDate(todo.dateModified)}"),
                        Text(formatElapsedTime(todo.dateModified)),
                      ],
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
        tooltip: addTodoTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddTodoScreen extends StatefulWidget {
  final TodoItem? existingTodo;
  final double fontSize;
  final String currentLanguage;

  const AddTodoScreen({
    super.key,
    this.existingTodo,
    required this.fontSize,
    required this.currentLanguage,
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
                    AppLocalizations.getText('title', currentLanguage),
              ),
              style: TextStyle(fontSize: fontSize),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              showCursor: true,
              cursorWidth: 2.0,
              cursorColor: Theme.of(context).primaryColor,
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
                final now = DateTime.now();
                Navigator.pop(
                  context,
                  TodoItem(
                    title: _controller.text,
                    imagePath: imagePath,
                    dateCreated: widget.existingTodo?.dateCreated ?? now,
                    dateModified: widget.existingTodo != null ? now : now,
                  ),
                );
              },
              child: Text(AppLocalizations.getText('save', currentLanguage)),
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
  final DateTime dateCreated;
  final DateTime dateModified; // dateModified 추가

  TodoItem({
    required this.title,
    this.imagePath,
    required this.dateCreated,
    required this.dateModified,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'imagePath': imagePath,
      'dateCreated': dateCreated.toIso8601String(),
      'dateModified': dateModified.toIso8601String(), // 저장
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      title: json['title'],
      imagePath: json['imagePath'],
      dateCreated: json['dateCreated'] != null
          ? DateTime.parse(json['dateCreated'])
          : DateTime.now(),
      dateModified: json['dateModified'] != null
          ? DateTime.parse(json['dateModified'])
          : DateTime.now(),
    );
  }
}

// settings_screen.dart 기존 동일, 변경 없음
// 단, 필요하다면 deleteTooltip 등에 대한 localization 추가 가능.
