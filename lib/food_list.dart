//food_list.dart:
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late Stream<List<Map<String, dynamic>>> foodStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream to listen for changes in the Firestore collection
    foodStream = _getFoodItems();
  }

  Stream<List<Map<String, dynamic>>> _getFoodItems() {
    // Replace 'restaurants' and 'foods' with your Firestore collection names
    return FirebaseFirestore.instance
        .collection('restaurants')
        .doc('yourRestaurantId') // Provide your restaurant ID
        .collection('foods')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Add the document ID to the data map
        data['docId'] = doc.id;
        return data;
      }).toList();
    });
  }

  Widget _buildFoodList(List<Map<String, dynamic>> foodItems) {
    return ListView.builder(
      itemCount: foodItems.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            leading: CircleAvatar(
              // You can display the food image here
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
                // Implement logic to mark the food as taken or remove it from the list
                // You can update the Firestore database accordingly
                _markFoodAsTaken(foodItems[index]['docId']);
              },
              child: Text('Taken'),
            ),
          ),
        );
      },
    );
  }

  void _markFoodAsTaken(String foodId) {
    // Implement your logic here to update the Firestore database
    // For example:
    FirebaseFirestore.instance
        .collection('restaurants')
        .doc('uid') // Provide your restaurant ID
        .collection('foods')
        .doc(foodId)
        .update({'taken': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food List'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: foodStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Map<String, dynamic>> foodItems = snapshot.data ?? [];
            return _buildFoodList(foodItems);
          }
        },
      ),
    );
  }
}