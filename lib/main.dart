import 'package:agrisol/ui/auth/forget_password.dart';
import 'package:agrisol/ui/auth/login.dart';
import 'package:agrisol/ui/posts/add_post.dart';
import 'package:agrisol/ui/posts/posts.dart';
import 'package:agrisol/ui/auth/signup.dart';
import 'package:agrisol/ui/saved_posts/saved_posts.dart';
import 'package:agrisol/ui/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'data/AuthRepository.dart';
import 'data/user_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put<AuthRepository>(AuthRepository(), permanent: true);
  Get.put<UserRepository>(UserRepository(), permanent: true);

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
        GetPage(name: "/posts", page: () =>  PostsPage(), binding: PostsBinding()),
        GetPage(name: "/addPost", page: () =>  AddPostPage(), binding: AddPostBinding()),
        GetPage(name: "/savedPosts", page: () => SavedPostsScreen()),
        GetPage(name: "/profile", page: () => ProfilePage()), // Profile page route
      ],

      initialRoute: '/login',
    );
  }
}
