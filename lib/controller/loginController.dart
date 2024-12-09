import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:kcmit/view/studentScreen/HomeMain.dart';
import 'package:kcmit/view/studentScreen/sauthentication/loginAsStudent.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  String LOGINKEY = 'isLogin';

  Future<void> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool(LOGINKEY) ?? false;

    if (isLoggedIn) {
      Get.to(StHomeMain());
    } else {
      Get.offAll(LoginAsStudent());
    }
  }

  void login() async {
    print("Username: ${username.text}");
    print("Password: ${password.text}");

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(LOGINKEY, true);

    Get.to(StHomeMain());
  }

  void logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(LOGINKEY, false);

    Get.offAll(LoginAsStudent());
  }
}
