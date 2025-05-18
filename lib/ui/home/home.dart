import 'package:agrisol/data/AuthRepository.dart';
import 'package:agrisol/ui/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agrisol/ui/add_post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    AuthRepository().logout();
    Get.offAll(const LoginPage());
  }

  void _navigateToAddPost() {
    Get.to(() => const AddPostPage(), binding: AddPostBinding());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Agri-Sol!'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.outline,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPost,
        child: const Icon(Icons.add),
        tooltip: 'Add Post',
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings'
          ),
        ],
      ),
    );
  }
}