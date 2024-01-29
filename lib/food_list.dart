// list.dart
import 'package:flutter/material.dart';

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<Map<String, dynamic>> foodItems = [
    {
      'foodName': 'Aglio Olio Pasta',
      'quantity': '2',
      'category': 'Western',
      'dietaryRestriction': 'Vegetarian'
    },
    {
      'foodName': 'Teriyaki Chicken',
      'quantity': '1',
      'category': 'Fusion',
      'dietaryRestriction': 'None'
    },
    {
      'foodName': 'Brownie Sundae',
      'quantity': '2',
      'category': 'Dessert',
      'dietaryRestriction': 'Vegetarian'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food List'),
      ),
      body: ListView.builder(
        itemCount: foodItems.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.lightBlue[200],
                child: Text('Img'),
              ),
              title: Text(foodItems[index]['foodName']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quantity: ${foodItems[index]['quantity']}'),
                  Text('Category: ${foodItems[index]['category']}'),
                  Text(
                      'Dietary Restriction: ${foodItems[index]['dietaryRestriction']}'),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  _markFoodAsTaken(index);
                },
                child: Text('Taken'),
              ),
            ),
          );
        },
      ),
    );
  }

  void _markFoodAsTaken(int index) {
    setState(() {
      // Remove the food item from the list
      foodItems.removeAt(index);
    });
  }
}
