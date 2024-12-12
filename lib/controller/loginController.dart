import 'package:get/get.dart';
import 'package:kcmit/view/authentication/loginPage.dart';
import 'package:kcmit/view/studentScreen/HomeMain.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  Future<void> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLogin') ?? false;

    if (isLoggedIn) {
      Get.offAll(() => StHomeMain());
    } else {
      Get.offAll(() => LoginPage());
    }
  }
}
