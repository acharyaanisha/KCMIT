import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/studentScreen/stProfile.dart';
import 'package:kcmit/view/studentScreen/studentToken.dart';
import 'package:provider/provider.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  String errorMessage = '';
  String successMessage = '';


  final List<String> allowedExtensions = ['png', 'jpg', 'jpeg'];

  Future<void> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {

        final fileExtension = path.extension(pickedFile.path).toLowerCase();
        if (!allowedExtensions.contains(fileExtension.replaceAll('.', ''))) {
          setState(() {
            errorMessage = 'Only PNG, JPG, and JPEG formats are supported.';
          });
          return;
        }

        setState(() {
          _image = File(pickedFile.path);
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage = 'No image selected.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error picking image: $e';
      });
    }
  }


  Future<void> updateProfile() async {
    if (_image == null) {
      setState(() {
        errorMessage = 'Please select an image first.';
      });
      return;
    }

    final token = context.read<studentTokenProvider>().token;
    final url = Config.getStUploadProfile();

    setState(() {
      isLoading = true;
      errorMessage = '';
      successMessage = '';
    });

    try {

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(await http.MultipartFile.fromPath(
        'profile-picture',
        _image!.path,
        contentType: _getContentType(_image!.path),
      ));

      // Send the request
      final response = await request.send();

      if (response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        if (jsonResponse['success'] == true) {
          setState(() {
            successMessage = jsonResponse['message'] ?? 'Profile updated successfully!';
          });

          // Navigate to the profile screen after success
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StProfile()),
                  // (Route<dynamic> route) => false,
            );
          });
        } else {
          setState(() {
            errorMessage = jsonResponse['message'] ?? 'Failed to update profile.';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to update profile. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  MediaType _getContentType(String filePath) {
    final fileExtension = path.extension(filePath).toLowerCase();
    switch (fileExtension) {
      case '.png':
        return MediaType('image', 'png');
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          title: const Text("Upload Picture"),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile picture display
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

              const SizedBox(height: 20),


              if (successMessage.isNotEmpty)
                Text(
                  successMessage,
                  style: const TextStyle(color: Colors.green, fontSize: 16),
                ),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),

              const SizedBox(height: 20),

              // Update Profile button
              isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: updateProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xff323465),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Update Profile',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
