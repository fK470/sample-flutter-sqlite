import 'package:flutter/material.dart';
import 'models/todo.dart';
import 'database/database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<Todo> todos = [];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _loadTodos() async {
    final loadedTodos = await dbHelper.getTodos();
    setState(() {
      todos = loadedTodos;
      // チェックのついたアイテムを最後に移動
      todos.sort((a, b) =>
          a.isCompleted == b.isCompleted ? 0 : (a.isCompleted ? 1 : -1));
      // compareTo()メソッドをするパターン
      // todos.sort((a, b) => a.isCompleted.compareTo(b.isCompleted));
    });
  }

  void _addTodo() {
    if (_formKey.currentState!.validate()) {
      Todo newTodo = Todo(
        title: _titleController.text,
      );
      dbHelper.insertTodo(newTodo).then((_) {
        _loadTodos();
        _titleController.clear();
      });
    }
  }

  void _updateTodo(Todo todo) {
    todo.isCompleted = !todo.isCompleted;
    dbHelper.updateTodo(todo).then((_) {
      _loadTodos();
    });
  }

  void _deleteTodo(int id) {
    dbHelper.deleteTodo(id).then((_) {
      _loadTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ToDo List'),
      ),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter a title';
                        }
                        return null;
                      },
                      onTapOutside: (event) => FocusScope.of(context).unfocus(),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addTodo,
                    child: Text('Add'),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      decoration:
                          todo.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteTodo(todo.id!);
                    },
                  ),
                  trailing: Checkbox(
                    value: todo.isCompleted,
                    onChanged: (_) {
                      _updateTodo(todo);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
