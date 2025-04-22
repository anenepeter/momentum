import 'package:uuid/uuid.dart';

class Todo {
  final String id;
  String description;
  bool isCompleted;

  Todo({
    required this.id,
    required this.description,
    this.isCompleted = false,
  });

  Todo.create({
    required this.description,
    this.isCompleted = false,
  }) : id = const Uuid().v4();

  // Add copyWith method
  Todo copyWith({
    String? description,
    bool? isCompleted,
  }) {
    return Todo(
      id: id,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      description: json['description'],
      isCompleted: json['isCompleted'],
    );
  }
}