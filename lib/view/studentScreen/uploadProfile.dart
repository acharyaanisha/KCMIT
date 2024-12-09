import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kcmit/model/profileModel/studentProfileModel.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  StudentProfile? studentProfile;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: ClipRRect(
    borderRadius: const BorderRadius.vertical(
    bottom: Radius.circular(30),
        ),
          child: AppBar(
            title: Text("Upload Picture"),
          ),
      ),
      ),
      body: SingleChildScrollView(
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  ClipOval(
                    child: _image != null
                        ? Image.file(
                      _image!,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    )
                        : studentProfile?.profilePicture != null
                        ? Image.network(
                      studentProfile!.profilePicture!,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    )
                        : const Icon(
                      Icons.account_circle_outlined,
                      size: 120,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.blue),
                      onPressed: pickImage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
