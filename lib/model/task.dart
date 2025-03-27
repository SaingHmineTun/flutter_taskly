class Task {
  String content;
  DateTime timestamp;
  bool done;

  Task({required this.content, required this.timestamp, required this.done});

  factory Task.fromMap(Map map) {
    return Task(content: map['content'], timestamp: map['timestamp'], done: map['done']);
  }

  Map toMap() {
    return {
      "content": content,
      "timestamp": timestamp,
      "done": done
    };
  }
}
