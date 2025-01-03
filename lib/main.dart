import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kcmit/firebase.dart';
import 'package:kcmit/view/authentication/loginPage.dart';
import 'package:kcmit/view/parentScreen/parentTokenProvider.dart';
import 'package:kcmit/view/studentScreen/studentToken.dart';
import 'package:kcmit/view/teacherScreen/facultyToken.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  await FlutterSecureStorage().read(key: 'jwt_token');
  await Firebase.initializeApp();
  await FirebaseApi().initNotifications();

  // print("object:");

  // context.read<studentTokenProvider>().setToken(token);
  // context.read<studentTokenProvider>().getRoleFromToken(token);

  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // await prefs.setString('token', token);

  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => studentTokenProvider()),
          ChangeNotifierProvider(create: (_) => facultyTokenProvider()),
          ChangeNotifierProvider(create: (_) => parentTokenProvider()),
        ],
        child:
        MyApp()
    ),

  );
  // context.read<studentTokenProvider>().setToken(token);
  // context.read<studentTokenProvider>().getRoleFromToken(token);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme:  const AppBarTheme(
          backgroundColor: Color(0xff323465),
          titleTextStyle: TextStyle(color: Colors.white,fontSize: 25),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        scaffoldBackgroundColor:  Colors.white,
      ),
      home:  LoginPage(),
      color: Colors.white,
    );
  }
}