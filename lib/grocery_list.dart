import 'package:flutter/material.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widget/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];
  void addItem() async {
    final addedItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (context) => const NewItem()));
    if (addedItem == null) {
      return;
    } else {
      setState(() {
        _groceryItems.add(addedItem);
      });
    }
  }

  void removeItem(index) {
    setState(() {
      _groceryItems.remove(_groceryItems[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
        child: Text(
      "Oops\nNo items added yet...",
      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 25),
    ));
    if (_groceryItems.isNotEmpty) {
      setState(() {
        content = ListView.builder(
            itemCount: _groceryItems.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: ValueKey(_groceryItems[index].id),
                onDismissed: (direction) {
                  removeItem(index);
                },
                child: ListTile(
                  minTileHeight: 10,
                  leading: Container(
                    color: _groceryItems[index].category.color,
                    height: 24,
                    width: 24,
                  ),
                  title: Text(_groceryItems[index].name),
                  trailing: Text("${_groceryItems[index].quantity}"),
                ),
              );
            });
      });
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Groceries"),
          actions: [
            IconButton(
                onPressed: () => addItem(),
                icon: const Icon(
                  Icons.add,
                ))
          ],
        ),
        body: content);
  }
}
