import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'login_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _skinTypeController = TextEditingController();
  final _skinConcernsController = TextEditingController();
  final _allergiesController = TextEditingController();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late UserProfile _userProfile = UserProfile(
    name: '',
    age: 0,
    email: '',
    skinType: 'Normal',
    skinConcerns: '',
    allergies: '',
    productExperiences: [],
  );
  final List<String> _skinTypes = [
    'Normal',
    'Dry',
    'Oily',
    'Combination',
    'Sensitive',
  ];
  String _selectedSkinType = 'Normal';

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productReviewController =
      TextEditingController();
  String _selectedRating = '3';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      print('Current user: ${user?.uid}');
      print('User email: ${user?.email}');
      print('User display name: ${user?.displayName}');

      if (user == null) {
        print('No user logged in');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final docSnapshot =
          await _firestore.collection('users').doc(user.uid).get();
      print('Firestore data: ${docSnapshot.data()}');

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        print('Raw Firestore data: $data');

        final productExperiences =
            (data['productExperiences'] as List<dynamic>?)
                ?.map((e) => ProductExperience.fromMap(e))
                .toList() ??
            [];

        print('Loaded user data:');
        print('Username: ${data['username']}');
        print('Age: ${data['age']}');
        print('Email: ${data['email']}');
        print('Skin Type: ${data['skinType']}');
        print('Skin Concerns: ${data['skinConcerns']}');
        print('Allergies: ${data['allergies']}');
        print('Product Experiences count: ${productExperiences.length}');

        setState(() {
          _userProfile = UserProfile(
            name: data['username'] ?? '',
            age: data['age'] ?? 0,
            email: data['email'] ?? '',
            skinType: data['skinType'] ?? 'Normal',
            skinConcerns: data['skinConcerns'] ?? '',
            allergies: data['allergies'] ?? '',
            productExperiences: productExperiences,
          );

          print('Setting form fields with values:');
          print('Name: ${_userProfile.name}');
          print('Age: ${_userProfile.age}');
          print('Email: ${_userProfile.email}');
          print('Skin Type: ${_userProfile.skinType}');
          print('Skin Concerns: ${_userProfile.skinConcerns}');
          print('Allergies: ${_userProfile.allergies}');

          _nameController.text = _userProfile.name;
          _ageController.text = _userProfile.age.toString();
          _emailController.text = _userProfile.email;
          _skinTypeController.text = _userProfile.skinType;
          _skinConcernsController.text = _userProfile.skinConcerns;
          _allergiesController.text = _userProfile.allergies ?? '';
          _selectedSkinType = _userProfile.skinType;
          _isLoading = false;
        });

        // Load profile image if exists
        if (data['profileImageUrl'] != null) {
          try {
            print('Loading profile image from URL: ${data['profileImageUrl']}');
            final ref = _storage.refFromURL(data['profileImageUrl']);
            final tempFile = File(
              '${Directory.systemTemp.path}/profile_image.jpg',
            );
            await ref.writeToFile(tempFile);
            setState(() {
              _profileImage = tempFile;
            });
            print('Profile image loaded successfully');
          } catch (e) {
            print('Error loading profile image: $e');
          }
        }
      } else {
        print('No user document found in Firestore, creating new profile');
        // Create new user profile in Firestore
        final initialUserData = {
          'username': user.displayName ?? '',
          'age': 0,
          'email': user.email ?? '',
          'skinType': 'Normal',
          'skinConcerns': '',
          'allergies': '',
          'productExperiences': [],
          'createdAt': FieldValue.serverTimestamp(),
        };

        print('Creating new user document with data: $initialUserData');
        await _firestore.collection('users').doc(user.uid).set(initialUserData);

        setState(() {
          _userProfile = UserProfile(
            name: user.displayName ?? '',
            age: 0,
            email: user.email ?? '',
            skinType: 'Normal',
            skinConcerns: '',
            allergies: '',
            productExperiences: [],
          );

          _nameController.text = _userProfile.name;
          _ageController.text = _userProfile.age.toString();
          _emailController.text = _userProfile.email;
          _skinTypeController.text = _userProfile.skinType;
          _skinConcernsController.text = _userProfile.skinConcerns;
          _allergiesController.text = _userProfile.allergies ?? '';
          _selectedSkinType = _userProfile.skinType;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_profileImage == null) return null;

    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final ref = _storage.ref().child('profile_images/${user.uid}.jpg');
      await ref.putFile(_profileImage!);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  void _showSkinTypeDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Skin Type'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  _skinTypes
                      .map(
                        (type) => RadioListTile<String>(
                          title: Text(type),
                          value: type,
                          groupValue: _selectedSkinType,
                          onChanged: (value) {
                            setState(() {
                              _selectedSkinType = value!;
                              _skinTypeController.text = value;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }

  void _addProductExperience() {
    if (_productNameController.text.isNotEmpty &&
        _productReviewController.text.isNotEmpty) {
      setState(() {
        _userProfile = _userProfile.copyWith(
          productExperiences: [
            ..._userProfile.productExperiences,
            ProductExperience(
              name: _productNameController.text,
              rating: int.parse(_selectedRating),
              review: _productReviewController.text,
              date: DateTime.now(),
            ),
          ],
        );
        _productNameController.clear();
        _productReviewController.clear();
        _selectedRating = '3';
      });
      Navigator.pop(context);
    }
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Product Experience'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _productNameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRating,
                  decoration: const InputDecoration(
                    labelText: 'Rating',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      ['1', '2', '3', '4', '5'].map((rating) {
                        return DropdownMenuItem(
                          value: rating,
                          child: Text('$rating Stars'),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRating = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _productReviewController,
                  decoration: const InputDecoration(
                    labelText: 'Review',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _addProductExperience,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 106, 56, 122),
                ),
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = _auth.currentUser;
        if (user == null) {
          print('No user logged in when trying to save');
          return;
        }

        final profileImageUrl = await _uploadProfileImage();

        final userData = {
          'username': _nameController.text,
          'age': int.parse(_ageController.text),
          'email': _emailController.text,
          'skinType': _skinTypeController.text,
          'skinConcerns': _skinConcernsController.text,
          'allergies': _allergiesController.text,
          'productExperiences':
              _userProfile.productExperiences.map((e) => e.toMap()).toList(),
          if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        };

        print('Saving user data: $userData');
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userData, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error saving profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _skinTypeController.dispose();
    _skinConcernsController.dispose();
    _allergiesController.dispose();
    _productNameController.dispose();
    _productReviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color.fromARGB(255, 106, 56, 122),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                      child:
                          _profileImage == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: const Color.fromARGB(
                          255,
                          106,
                          56,
                          122,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Personal Information Section
              const Text(
                'Personal Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Skin Information Section
              const Text(
                'Skin Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skinTypeController,
                decoration: InputDecoration(
                  labelText: 'Skin Type',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: _showSkinTypeDialog,
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your skin type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skinConcernsController,
                decoration: const InputDecoration(
                  labelText: 'Skin Concerns',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your skin concerns';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _allergiesController,
                decoration: const InputDecoration(
                  labelText: 'Allergies or Sensitivities',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Product Experiences Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Product Experiences',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _showAddProductDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Experience'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 106, 56, 122),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _userProfile.productExperiences.length,
                itemBuilder: (context, index) {
                  final experience = _userProfile.productExperiences[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(experience.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (i) => Icon(
                                  Icons.star,
                                  size: 16,
                                  color:
                                      i < experience.rating
                                          ? Colors.amber
                                          : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Text(experience.review),
                          Text(
                            experience.date.toString().split(' ')[0],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _userProfile = _userProfile.copyWith(
                              productExperiences: List.from(
                                _userProfile.productExperiences,
                              )..removeAt(index),
                            );
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 106, 56, 122),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Save Profile',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error signing out: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
