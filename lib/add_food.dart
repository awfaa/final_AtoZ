import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:final_atoz/services/auth/auth_service.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({Key? key}) : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  late TextEditingController _foodNameController;
  late TextEditingController _quantityController;
  late String _selectedCategory = 'Malay'; // Provide a default value
  late String _selectedDietaryRestriction = 'None';
  PickedFile? _pickedImage; // Nullable type
  late ImagePicker _imagePicker;
  late CameraController _cameraController;
  late Future<void>? _initializeControllerFuture; // Nullable type

  @override
  void initState() {
    super.initState();
    _foodNameController = TextEditingController();
    _quantityController = TextEditingController();
    _imagePicker = ImagePicker();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    try {
      await _cameraController.initialize();
      _initializeControllerFuture = _cameraController.initialize();
    } catch (e) {
      print('Error initializing camera: $e');
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _pickImage() async {
    try {
      XFile? pickedImage =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      setState(() {
        _pickedImage = pickedImage as PickedFile?;
      });
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _takePicture() async {
    try {
      await _initializeControllerFuture!;
      final XFile image = await _cameraController.takePicture();
      setState(() {
        _pickedImage = PickedFile(image.path);
      });
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<String> uploadImageToStorage(PickedFile? pickedImage) async {
    try {
      if (pickedImage == null) {
        return ''; // Return empty string if no image is selected
      }

      File file = File(pickedImage.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      Reference storageReference =
          FirebaseStorage.instance.ref().child('food_images/$fileName.jpg');
      await storageReference.putFile(file);

      String imageUrl = await storageReference.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Error uploading image to storage: $e');
      throw Exception('Error uploading image to storage');
    }
  }

  void _addFoodToDatabase() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.firebaseAuth.currentUser;

      if (user != null) {
        String restaurantId = user.uid;
        String foodName = _foodNameController.text;
        String quantity = _quantityController.text;

        // Store additional food details
        String category = _selectedCategory;
        String dietaryRestriction = _selectedDietaryRestriction;

        // Upload the image to Firebase Storage
        String imagePath = await uploadImageToStorage(_pickedImage);

        // Get the Firestore instance
        final firestoreInstance = FirebaseFirestore.instance;

        // Add data to Firestore
        await firestoreInstance
            .collection('restaurants')
            .doc(restaurantId)
            .collection('foods')
            .add({
          'foodName': foodName,
          'quantity': quantity,
          'category': category,
          'dietaryRestriction': dietaryRestriction,
          'imagePath': imagePath,
          'taken': false,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food added to database successfully'),
          ),
        );
      }
    } catch (e) {
      print('Error adding food to database: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding food to database'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _foodNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _pickedImage != null
                  ? Image.file(File(_pickedImage!.path))
                  : FutureBuilder(
                      future: _initializeControllerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return CameraPreview(_cameraController);
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _pickImage();
                    },
                    child: const Text('Pick Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[200],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _takePicture();
                    },
                    child: const Text('Take Picture'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[200],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _foodNameController,
                decoration: const InputDecoration(
                  labelText: 'Food Name',
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField(
                value: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                items: ['Malay', 'Western', 'Fusion', 'Dessert']
                    .map<DropdownMenuItem<String>>(
                  (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  },
                ).toList(),
                decoration: const InputDecoration(
                  labelText: 'Food Category',
                ),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField(
                value: _selectedDietaryRestriction,
                onChanged: (value) {
                  setState(() {
                    _selectedDietaryRestriction = value!;
                  });
                },
                items: ['None', 'Vegetarian', 'Vegan']
                    .map<DropdownMenuItem<String>>(
                  (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  },
                ).toList(),
                decoration: const InputDecoration(
                  labelText: 'Dietary Restriction',
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _addFoodToDatabase();
                },
                child: const Text('Add Food'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[200],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
