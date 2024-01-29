//home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_atoz/services/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Info'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('restaurants')
                  .doc(user!.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData ||
                    snapshot.data == null ||
                    !snapshot.data!.exists) {
                  return const Text('No restaurant information found.');
                }

                var restaurantData =
                    snapshot.data!.data() as Map<String, dynamic>;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${restaurantData['restaurantName']}',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on),
                                const SizedBox(width: 8),
                                Text(
                                  '${restaurantData['address']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.phone),
                                const SizedBox(width: 8),
                                Text(
                                  '${restaurantData['contact']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                );
              },
            ),
            const Text(
              'Available Food:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LatestNotTakenFoodList(),
            ),
          ],
        ),
      ),
    );
  }
}

class LatestNotTakenFoodList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getLatestNotTakenFoodItems(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Map<String, dynamic>> foodItems = snapshot.data ?? [];
          return _buildFoodList(foodItems);
        }
      },
    );
  }

  Stream<List<Map<String, dynamic>>> _getLatestNotTakenFoodItems(
      BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userId = currentUser.uid;

      return FirebaseFirestore.instance
          .collection('restaurants')
          .doc(userId)
          .collection('foods')
          .where('taken', isEqualTo: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['docId'] = doc.id;
          return data;
        }).toList();
      }).handleError((error) {
        print('Error fetching not taken food items: $error');
        return [];
      });
    } else {
      return Stream.value([]);
    }
  }

  Widget _buildFoodList(List<Map<String, dynamic>> foodItems) {
    foodItems.sort((a, b) => b['docId'].compareTo(a['docId']));
    return ListView.builder(
      itemCount: foodItems.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(8.0),
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
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('foods')
        .doc(foodId)
        .update({'taken': true});
  }
}
