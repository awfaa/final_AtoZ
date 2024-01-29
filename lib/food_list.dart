import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userId = currentUser.uid;
      foodStream = _getFoodItems(userId);
    } else {
      // If no user is logged in, set an empty stream
      foodStream = Stream.value([]);
    }
  }

  Stream<List<Map<String, dynamic>>> _getFoodItems(String userId) {
    return FirebaseFirestore.instance
        .collection('restaurants')
        .doc(userId) // Use the user's uid as the restaurant identifier
        .collection('foods')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['docId'] = doc.id;
        return data;
      }).toList();
    }).handleError((error) {
      print('Error fetching food items: $error');
      // Return an empty list on error
      return [];
    });
  }

  Widget _buildFoodList(List<Map<String, dynamic>> foodItems) {
    foodItems.sort((a, b) => b['docId'].compareTo(a['docId']));
    return ListView.builder(
      itemCount: foodItems.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            leading: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(foodItems[index]['imagePath']),
                  fit: BoxFit.cover,
                ),
              ),
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
                _markFoodAsTaken(foodItems[index]['docId']);
              },
              child: Text(foodItems[index]['taken'] ? 'Taken' : 'Not Taken'),
            ),
          ),
        );
      },
    );
  }

  void _markFoodAsTaken(String foodId) {
    FirebaseFirestore.instance
        .collection('restaurants')
        .doc(FirebaseAuth.instance.currentUser!.uid) // Use the user's uid
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
