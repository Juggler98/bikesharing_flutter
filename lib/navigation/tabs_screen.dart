import 'package:bikesharing/navigation/map_screen.dart';
import 'package:flutter/material.dart';

import '../main_drawer.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({Key? key}) : super(key: key);

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  late List<Widget> _pages;

  late PageController _pageController;

  int _selectedPageIndex = 1;

  @override
  void initState() {
    super.initState();
    _pages = [
      const MapScreen(),
    ];
    _pageController = PageController(initialPage: _selectedPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectPage(int index) {
    if (_selectedPageIndex != index) {
      setState(() {
        _selectedPageIndex = index;
        _pageController.jumpToPage(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bikesharing',
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.directions_bike_outlined),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              tooltip: 'Bikesharing',
              onPressed: () async {}),
        ],
      ),
      drawer: MainDrawer(),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _selectedPageIndex != 2 ? null : null,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: _selectPage,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.blue,
        currentIndex: _selectedPageIndex,
        //selectedIconTheme: IconThemeData(color: Colors.green),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Domov',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'História jázd',
          ),
        ],
      ),
    );
  }
}
