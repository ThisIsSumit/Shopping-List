import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/category.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widget/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  String _error = 'null';
  bool _isloading = true;
  List<GroceryItem> _groceryItems = [];
  void loadItems() async {
    final url = Uri.https('shopping-list-c31a2-default-rtdb.firebaseio.com',
        'shopping-list.json');
    final response = await http.get(url);

    try {
      final List<GroceryItem> loadedItems = [];
      final Map<String, dynamic> listData = jsonDecode(response.body);
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.lable == item.value['category'])
            .value;
        loadedItems.add(GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category));
      }
      setState(() {
        _groceryItems = loadedItems;
        _isloading = false;
      });
      if (response.body == 'null') {
        setState(() {
          _isloading = false;
        });
        return;
      }
    } catch (e) {
      setState(() {
        _error = 'Something went wrong';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (context) => const NewItem()));
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https('shopping-list-c31a2-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
        child: (_error == 'null')
            ? const Text(
                "Oops\nNo items added yet...",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 25),
              )
            : Text(
                _error,
                style:
                    const TextStyle(fontWeight: FontWeight.w400, fontSize: 25),
              ));
    if (_isloading) {
      setState(() {
        content = const Center(
          child: CircularProgressIndicator(),
        );
      });
    }
    if (_groceryItems.isNotEmpty) {
      setState(() {
        content = ListView.builder(
            itemCount: _groceryItems.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: ValueKey(_groceryItems[index].id),
                onDismissed: (direction) {
                  removeItem(_groceryItems[index]);
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
      body: content,
    );
  }
}
