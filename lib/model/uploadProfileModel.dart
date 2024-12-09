import 'dart:io';

class ProfileEdit {
  File? profilePictureName;


  ProfileEdit({
    this.profilePictureName,
  });

  factory ProfileEdit.fromJson(Map<String, dynamic> json) {
    return ProfileEdit(
      profilePictureName: json['profilePictureName'] ,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'profilePictureName': profilePictureName,
    };
  }
}
