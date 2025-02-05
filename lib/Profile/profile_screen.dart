import 'package:flutter/material.dart';
import 'package:classc_eats/Services/api_service.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart'; // Add permission_handler package

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? _image;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final response = await _apiService.fetchProfile();
    if (response.statusCode == 200) {
      setState(() {
        _userProfile = jsonDecode(response.body);
        _nameController.text = _userProfile!["name"];
        _emailController.text = _userProfile!["email"];
      });
    }
  }

  Future<void> _updateProfile() async {
    Map<String, String> profileData = {
      "name": _nameController.text,
      "email": _emailController.text,
    };

    final response = await _apiService.updateProfile(profileData, _image);

    if (response.statusCode == 200) {
      setState(() {
        _fetchUserProfile(); // Refresh user data
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update profile")),
        );
      }
    }
  }


  Future<void> _deleteAccount() async {
    final response = await _apiService.deleteAccount();
    if (response.statusCode == 200) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteAccount(); // Proceed with deletion
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  // Update the _pickImage function to choose between camera and gallery
  Future<void> _pickImage() async {
    // Request permissions
    await _requestPermissions();

    // Show an option to choose between camera and gallery
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(context); // Close the bottom sheet
                final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context); // Close the bottom sheet
                final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Function to request camera and gallery permissions
  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.photos,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: OrientationBuilder(
        builder: (context, orientation) {
          bool isPortrait = orientation == Orientation.portrait;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: isPortrait
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildProfileForm(),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildProfileForm(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildProfileForm() {
    return [
      _buildProfileImage(),
      const SizedBox(height: 20),
      TextField(
        controller: _nameController,
        decoration: const InputDecoration(labelText: "Name"),
      ),
      TextField(
        controller: _emailController,
        decoration: const InputDecoration(labelText: "Email"),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: _updateProfile,
        child: const Text("Update Profile"),
      ),
      TextButton(
        onPressed: _showDeleteConfirmationDialog,
        style: TextButton.styleFrom(foregroundColor: Colors.red),
        child: const Text("Delete Account"),
      ),
    ];
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 50,
        backgroundImage: _image != null
            ? FileImage(_image!)
            : _userProfile?["profile_picture"] != null
            ? NetworkImage("https://classiceats.online/storage/" +
            _userProfile!["profile_picture"]) as ImageProvider
            : null,
        child: _image == null && _userProfile?["profile_picture"] == null
            ? const Icon(Icons.person, size: 50)
            : null,
      ),
    );
  }
}
