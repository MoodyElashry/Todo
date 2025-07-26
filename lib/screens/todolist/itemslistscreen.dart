import 'package:flutter/material.dart';
import 'package:finalflutter/services/data/item_service.dart';
import 'package:finalflutter/models/item_model.dart';
import 'package:finalflutter/screens/todolist/detaileditem.dart';
import 'package:finalflutter/screens/user/signin.dart';
import 'package:finalflutter/services/data/task_complete.dart';
import 'package:finalflutter/screens/user/profile.dart';
import 'package:finalflutter/services/user/profile.dart';

class HeroListView extends StatefulWidget {
  const HeroListView({super.key});

  @override
  State<HeroListView> createState() => _HeroListViewState();
}

class _HeroListViewState extends State<HeroListView> {
  final Service itemsService = Service();
  late Future<List<Item>> itemsFuture;

  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  String? profileImageUrl;


  @override
  void initState() {
    super.initState();
    itemsFuture = Future.value([]);
    loadItems(); // only call this
  }

  Future<void> loadItems() async {
    try {
      final fetchedItems = await itemsService.getItems()!;
      final completed = await CompletedTaskStorage.getCompletedTasks();

      // Fetch profile image
      final profileService = ProfileService();
      final profile = await profileService.fetchAndSaveUsername();
      profileImageUrl = profile['image'];

      setState(() {
        itemsFuture = Future.value([...fetchedItems, ...completed]);
      });
    } on AuthException catch (e) {
      authService.clearToken();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SignIn()),
            (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("TODO List"),
            Row(
              children: [
                IconButton(
                  onPressed: loadItems,
                  icon: const Icon(Icons.refresh),
                ),
                InkWell(
                  onTap: (){Navigator.of(context).push(
                    MaterialPageRoute(builder: (context)=> ProfilePage()));
                  },

                  child: Hero(
                    tag: "profile",
                    child: CircleAvatar(
                      backgroundImage: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                          ? NetworkImage(profileImageUrl!)
                          : const NetworkImage('https://pbs.twimg.com/media/GJlF6wBbIAASZVW?format=jpg&name=360x360'),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Item>>(
        future: itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No items found.'));
          } else {
            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final bool isCompleted = item.isCompleted;
                final Color taskColor = isCompleted?Colors.green : Colors.red;
                final Icon icon = Icon(isCompleted?Icons.clear:Icons.check,color: taskColor,);
                return ListTile(
                  minTileHeight: 100,
                  title: Text(item.title),
                  leading: Hero(
                    tag: "hero_list_item_${item.id}",
                    child: Container(
                      width: 60,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: taskColor.withAlpha(30),
                      ),
                      child: icon
                    ),
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HeroListItemPage(item: item),
                      ),
                    );
                    await loadItems();
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          titleController.clear();
          bodyController.clear();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Add Item'),
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
                      itemsService.addItems(newItem);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Item added successfully!')),
                      );
                      await loadItems();

                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
