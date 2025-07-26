import 'package:flutter/material.dart';
import 'package:finalflutter/models/item_model.dart';
import 'package:finalflutter/services/data/item_service.dart';
import 'package:finalflutter/screens/user/signin.dart';
import 'package:finalflutter/services/data/task_complete.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
class HeroListItemPage extends StatefulWidget {
  final Item item;

  const HeroListItemPage({super.key, required this.item});

  @override
  State<HeroListItemPage> createState() => _HeroListItemPageState();
}

class _HeroListItemPageState extends State<HeroListItemPage> {
  final Service itemsService =    Service();
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  late Future<Item> detailedItemFuture;

  @override
  void initState() {
    super.initState();
    try {

    detailedItemFuture = itemsService.getDetailed(widget.item.id);


    } on AuthException catch (e) {
      authService.clearToken();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SignIn()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> refreshItem() async {
    setState(() {
      try {

        detailedItemFuture = itemsService.getDetailed(widget.item.id);


      } on AuthException catch (e) {
        authService.clearToken();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => SignIn()),
              (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = widget.item.isCompleted;
    final Color taskColor = isCompleted?Colors.green : Colors.red;
    final Icon icon = Icon(isCompleted?Icons.check:Icons.clear,color: taskColor,size: 100,);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Item"),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: refreshItem,
            ),
          ],
        ),
      ),
      body: FutureBuilder<Item>(
        future: detailedItemFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Item not found."));
          }

          final item = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Hero(
                  tag: "hero_list_item_${item.id}",
                  child: Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: taskColor.withAlpha(30),
                    ),
                    child: Center(
                      child: icon
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 25),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 25),
                Text(
                  "Created At: ${item.createdDate}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  "Last Updated: ${item.updatedDate}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 20),
        child:  isCompleted
            ? FloatingActionButton(
          heroTag: null,
          onPressed: () async {
            await CompletedTaskStorage.removeTask(widget.item.id);
            Navigator.pop(context);

          },
          child: const Icon(Icons.delete),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Delete Button
            FloatingActionButton(
              heroTag: null,
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Delete Item'),
                      content: const Text('Are you sure you want to delete this item?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          onPressed: () async {
                            await itemsService.delItems(widget.item.id);
                            Navigator.pop(context); // Close dialog
                            Navigator.pop(context); // Go back to list
                          },
                        ),
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Icon(Icons.delete_forever),
            ),

            // Edit Button
            FloatingActionButton(
              heroTag: null,
              onPressed: () {
                detailedItemFuture.then((item) {
                  titleController.text = item.title;
                  bodyController.text = item.description;

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Edit Item'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: titleController,
                              decoration: const InputDecoration(labelText: 'Title'),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: bodyController,
                              decoration: const InputDecoration(labelText: 'Description'),
                              maxLines: 3,
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              final newItem = PostItem(
                                title: titleController.text,
                                description: bodyController.text,
                              );

                              Navigator.of(context).pop(); // Close dialog
                              await itemsService.updateItems(newItem, widget.item.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Item updated successfully!')),
                              );
                              await refreshItem();
                            },
                            child: const Text('Update'),
                          ),
                        ],
                      );
                    },
                  );
                });
              },
              child: const Icon(Icons.edit),
            ),

            // Manual Refresh Button
            FloatingActionButton(
              heroTag: null,
              onPressed: () async {
                await itemsService.completeTask(
                  Item(
                    id: widget.item.id,
                    title: widget.item.title,
                    description: widget.item.description,
                    createdDate: widget.item.createdDate,
                    updatedDate: widget.item.updatedDate,
                    userId: widget.item.userId,
                    isCompleted: true, // ✅ mark as completed
                  ),
                );
                Navigator.pop(context);
              },
              child: const Icon(Icons.check),
            ),
          ],
        ),
      ),
    );
  }
}
