import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:finalflutter/services/user/profile.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:finalflutter/services/user/auth.dart';
import 'package:finalflutter/services/user/authgate.dart';
import 'package:shared_preferences/shared_preferences.dart';



class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileService profileService = ProfileService();
  AuthService authService = AuthService();
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  final petNameController = TextEditingController();
  final addressController = TextEditingController();
  File? imageController ;
  void _GetData() async {
    try {
      final data = await profileService.fetchAndSaveUsername();
      data['address'] != null ? addressController.text = data['address'] : addressController.clear();

      data['petName'] != null ? petNameController.text = data['petName'] : petNameController.clear();
      setState(() {
        profileData = data;
        isLoading = false;
      });
    } catch (e) {
      print("Failed to load profile: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _GetData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Profile',
              style: TextStyle(fontSize: 26),
            ),
            DarkModeToggleButton()

          ],
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(),
              child: Align(
                alignment: Alignment.center,
                child: Hero(
                  tag: "profile",
                  child: ProfileImagePicker(
                    onImageSelected: (file) {
                      imageController = file;
                    },
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  profileData?['username'] ?? 'No username',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
              child: SizedBox(
                height: 70,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        // color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: TextField(
                        controller: petNameController,
                        cursorColor: Colors.black,
                        style: TextStyle(
                          color: Colors.black
                        ),
                        decoration: const InputDecoration(
                    
                          filled: false,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                    
                          labelText: 'Pet Name',
                    
                        )
                      )
                    
                      ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
              child: SizedBox(
                height: 70,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        // color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: TextField(
                            controller: addressController,
                            cursorColor: Colors.black,
                            style: TextStyle(
                                color: Colors.black
                            ),
                            decoration: const InputDecoration(

                              filled: false,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,

                              labelText: 'Address',

                            )
                        )

                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
      Padding(
        padding: const EdgeInsets.only(left: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FloatingActionButton(
              heroTag: null,
              onPressed: () async {
                await authService.clearToken();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => AuthGate()), // New route to push
                      (Route<dynamic> route) => false,
                );

                setState(() {
                });
              },
              child: Icon(Icons.logout),
            ),
            FloatingActionButton(
              heroTag: null,
              onPressed: () async {
              await profileService.updateProfile(petName: petNameController.text,address: addressController.text,imageFile: imageController);
                _GetData();
              setState(() {
              });
            },
              child: Icon(Icons.check),
            ),

          ],
        ),
      ),

    );
  }
}


class ProfileImagePicker extends StatefulWidget {
  final Function(File?) onImageSelected;
  const ProfileImagePicker({super.key, required this.onImageSelected});

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _selectedImage;



  Future<void> _pickImage() async {
    var status = await Permission.photos.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied to access photos')),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      widget.onImageSelected(_selectedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[300],
        backgroundImage:
        _selectedImage != null ? FileImage(_selectedImage!) : NetworkImage('https://pbs.twimg.com/media/GJlF6wBbIAASZVW?format=jpg&name=360x360'),
        child:
             const Icon(Icons.add_a_photo, size: 30, color: Colors.white)
      ),
    );
  }
}

class DarkModeToggleButton extends StatefulWidget {
  const DarkModeToggleButton({super.key});

  @override
  State<DarkModeToggleButton> createState() => _DarkModeToggleButtonState();
}

class _DarkModeToggleButtonState extends State<DarkModeToggleButton> {
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _loadDarkMode();
  }

  Future<void> _loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true; // default dark
    setState(() {
      _isDarkMode = isDark;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      _isDarkMode = value;
    });
    // No restart or theme change here, since you said you handle that on app restart
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wb_sunny, color: Colors.amber),
        const SizedBox(width: 8),
        Switch(
          value: _isDarkMode,
          onChanged: (value) {
            setState(() {
              _isDarkMode = value;
              // Save to shared prefs here if needed
            });
            // Show alert dialog after toggling
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Restart Required'),
                content: const Text('You must restart the app for the theme change to take effect.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        const Icon(Icons.nights_stay, color: Colors.indigo),
      ],
    );


  }
}