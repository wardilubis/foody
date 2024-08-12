import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'timeline.dart';
import 'addPost.dart';
import 'profile.dart';
import 'login_page.dart'; // Import halaman login

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  static List<Widget> _widgetOptions = <Widget>[
    TimelinePage(),
    AddPostPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken'); // Menghapus token dari SharedPreferences
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoginPage()), // Kembali ke halaman login
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Foody', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Memanggil fungsi logout
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Timeline',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Add Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      ),
    );
  }
}
