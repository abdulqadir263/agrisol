import 'package:agrisol/ui/forget_password.dart';
import 'package:agrisol/ui/home/home.dart';
import 'package:agrisol/ui/login.dart';
import 'package:agrisol/ui/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Agri-Sol",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
            useMaterial3: true,
      ),

      getPages: [
        GetPage(name: "/login", page: () =>  LoginPage(), binding: LoginBinding()),
        GetPage(name: "/signup", page: () =>  SignupPage(), binding: SignUpBinding()),
        GetPage(name: "/forget_password", page: () =>  ResetPasswordPage(), binding: ResetPasswordBinding()),
        GetPage(name: "/home", page: () =>  HomePage())
      ],

      initialRoute: '/login',

      initialBinding: LoginBinding(),
      home: LoginPage(),
    );
  }

}