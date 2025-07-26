import 'dart:math';
import 'dart:ui';
Color randomOpaqueColor() {
  return Color(Random().nextInt(0xffffffff)).withAlpha(0xff);
}
class Item {
  final int id;
  final String title;
  final String description;
  final DateTime createdDate;
  final DateTime updatedDate;
  final int userId;
  final bool isCompleted; // ✅ New field

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.createdDate,
    required this.updatedDate,
    required this.userId,
    this.isCompleted = false, // ✅ default to false
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdDate: DateTime.parse(json['createdDate']),
      updatedDate: DateTime.parse(json['updatedDate']),
      userId: json['userId'],
      isCompleted: json['isCompleted'] ?? false, // ✅ support from local
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdDate': createdDate.toIso8601String(),
      'updatedDate': updatedDate.toIso8601String(),
      'userId': userId,
      'isCompleted': isCompleted, // ✅ save it
    };
  }
}

class PostItem {
  final String title;
  final String description;

  PostItem({required this.title, required this.description});

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
  };
}
