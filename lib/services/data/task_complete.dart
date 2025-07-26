import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finalflutter/models/item_model.dart';

class CompletedTaskStorage {
  static const String _key = 'completed_tasks';
  static Future<void> removeTask(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_key) ?? [];

    // Decode JSON strings into Item objects
    final List<Item> tasks = tasksJson.map((e) => Item.fromJson(jsonDecode(e))).toList();

    // Filter out the task to remove
    final updatedTasks = tasks.where((task) => task.id != id).toList();

    // Encode back to JSON strings
    final updatedJson = updatedTasks.map((task) => jsonEncode(task.toJson())).toList();

    // Save the updated list
    await prefs.setStringList(_key, updatedJson);
  }
  static Future<void> addCompletedTask(Item item) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getCompletedTasks();
    tasks.add(item);
    final encoded = tasks.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, encoded);
  }

  static Future<List<Item>> getCompletedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList(_key) ?? [];
    return encoded.map((e) => Item.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> clearCompletedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
