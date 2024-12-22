class Todo {
  int? id;
  String title;
  bool isCompleted;

  // アプリ側で新しいTodoを作成するときに使うコンストラクタ
  Todo({
    this.id,
    required this.title,
    this.isCompleted = false,
  });

  // データベース ⟺ fromMap/toMap ⟺ アプリ

  // データベースからデータを取得するときに使うコンストラクタ
  // データベースから取得したMapをアプリで扱いやすいTodoオブジェクトに変換
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
    );
  }

  // データベースに保存するためにTodoオブジェクトをMapに変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }
}
