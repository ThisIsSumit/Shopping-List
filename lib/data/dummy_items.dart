import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/data/categories.dart';
enum Categories { meat, dairy, fruit ,vegetables, carbs,sweets ,convenience,spices ,hygiene ,other}
final groceryItems = [
  GroceryItem(
      id: 'a',
      name: 'Milk',
      quantity: 1,
      category: categories[Categories.dairy]!),
  GroceryItem(
      id: 'b',
      name: 'Bananas',
      quantity: 5,
      category: categories[Categories.fruit]!),
  GroceryItem(
      id: 'c',
      name: 'Beef Steak',
      quantity: 1,
      category: categories[Categories.meat]!),
];



