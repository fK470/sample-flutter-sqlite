import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/todo.dart'; // Todoモデルクラスをインポート

class DatabaseHelper {
  static final _databaseName = "TodoDatabase.db";
  static final _databaseVersion = 1;

  static final table = 'todos';

  static final columnId = 'id';
  static final columnTitle = 'title';
  static final columnIsCompleted = 'isCompleted';

  // シングルトンクラスにする
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Databaseオブジェクトは、データベースへの唯一のリファレンスを持つようにする
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // データベースを開き、存在しない場合は作成する
  _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    print(path);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQLを使ってデータベーステーブルを作成
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnTitle TEXT NOT NULL,
            $columnIsCompleted INTEGER NOT NULL
          )
          ''');
  }

  // Todoの挿入
  Future<int> insertTodo(Todo todo) async {
    Database db = await instance.database;
    return await db.insert(table, todo.toMap());
  }

  // 全てのTodoを取得
  Future<List<Todo>> getTodos() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  // Todoの更新
  Future<int> updateTodo(Todo todo) async {
    Database db = await instance.database;
    return await db.update(table, todo.toMap(),
        where: '$columnId = ?', whereArgs: [todo.id]);
  }

  // Todoの削除
  Future<int> deleteTodo(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
