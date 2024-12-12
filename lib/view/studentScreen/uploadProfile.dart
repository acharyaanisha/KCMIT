import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kcmit/model/profileModel/studentProfileModel.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/studentScreen/stProfile.dart';
import 'package:kcmit/view/studentScreen/studentToken.dart';
import 'package:provider/provider.dart';
import 'package:http_parser/http_parser.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  StudentProfile? studentProfile;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  String errorMessage = '';
  String successMessage = '';


  Future<void> saveImage(File image) async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });

    print('Image saved to server: ${image.path}');
  }


  Future<void> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });


        saveImage(_image!);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> updateProfile() async {
    final token = context.read<studentTokenProvider>().token;
    final url = Config.getStUploadProfile();

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';


      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image!.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        if (jsonResponse['code'] == '0') {
          setState(() {
            successMessage = 'Profile updated successfully!';
            errorMessage = '';
          });

          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StProfile()),
            );
          });
        } else {
          setState(() {
            errorMessage =
                jsonResponse['message'] ?? 'Failed to update profile.';

          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to update profile. Please try again.';

        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred while updating the profile.';

      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
          child: AppBar(
            title: Text("Upload Picture"),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
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
                        ? isLoading
                        ? CircularProgressIndicator() // Show loading while image is fetched
                        : Image.network(
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

            // Show success or error messages
            if (successMessage.isNotEmpty)
              Text(
                successMessage,
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),

            // Update Profile button
            ElevatedButton(
              onPressed: () {
                updateProfile();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xff456b9d),
              ),
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }

}