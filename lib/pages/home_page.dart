import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navigation.dart';
import 'profile_page.dart';
import 'tasks_page.dart';
import 'portfolio_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      TasksPage(),
      PortfolioPage(),
      ProfilePage(),
    ];
    final List<String> titles = <String>[
      TasksPage.title,
      PortfolioPage.title,
      ProfilePage.title,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    );
  }
}
