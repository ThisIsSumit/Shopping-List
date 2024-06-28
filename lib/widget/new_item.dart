import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/data/dummy_items.dart';

import 'package:http/http.dart' as http;
import 'package:shopping_list/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  bool _isSending = false;
  GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  String? _enteredName;
  int _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.fruit]!;
  void _saveItem() async {
    _globalKey.currentState!.validate();

    _globalKey.currentState!.save();
    setState(() {
      _isSending = true;
    });
    final url = Uri.https('shopping-list-c31a2-default-rtdb.firebaseio.com',
        'shopping-list.json');
    final response = await http.post(url,
        headers: {'content-Type': 'application/json'},
        body: jsonEncode({
          'name': _enteredName!,
          'quantity': _enteredQuantity,
          'category': _selectedCategory.lable
        }));

    print(response.body);
    print(response.statusCode);
    final Map<String, dynamic> resData = jsonDecode(response.body);
    if (!context.mounted) {
      return;
    } else {
      Navigator.of(context).pop(GroceryItem(
          id: resData['name'],
          name: _enteredName!,
          quantity: _enteredQuantity,
          category: _selectedCategory));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a new item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _globalKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFormField(
                onSaved: (newValue) => _enteredName = newValue,
                maxLength: 50,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length == 1 ||
                      value.trim().length > 50) {
                    return "Must be between 1 to 50";
                  }
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      onSaved: (newValue) {
                        _enteredQuantity = int.parse(newValue!);
                      },
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      decoration: const InputDecoration(labelText: "Quantity"),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return "Enter a valid positive number";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                        value: _selectedCategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                                value: category.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: category.value.color,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(category.value.lable)
                                  ],
                                ))
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        }),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _globalKey.currentState!.reset();
                          },
                    child: const Text("Reset"),
                  ),
                  ElevatedButton(
                      onPressed: _isSending ? null : _saveItem,
                      child: _isSending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(),
                            )
                          : const Text("Add Item"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
