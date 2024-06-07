import 'package:api_dados/views/home/home_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:api_dados/views/home/pages/save_data_page.dart';
import 'package:api_dados/views/home/pages/show_data_page.dart';
import 'package:badges/badges.dart' as badges;

class UserDataPage extends StatefulWidget {
  const UserDataPage({Key? key}) : super(key: key);

  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  int _selectedIndex = 0;
  late PageController _pageController;
  int _savedDataCount = 0;
  final HomeScreenState _homeScreenState = HomeScreenState();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  // Função para incrementar o contador de usuários salvos
  void _incrementSavedUserCount() {
    setState(() {
      _savedDataCount++;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        _homeScreenState.resetNotificationCount(); //zerar o contador
      }
      _pageController.jumpToPage(index);
    });
  }

  // Função para zerar o contador de usuários salvos
  void _resetSavedUserCount() {
    setState(() {
      _savedDataCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Data'),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          ShowDataPage(
            onUserSaved: () {
              setState(() {
                _homeScreenState.incrementNotificationCount();
              });
            },
            onUserDeleted: () {},
            // ignore: avoid_types_as_parameter_names
            onUserSavedStatusChanged: (bool) {},
          ),
          SavedDataPage(
            onView: () {},
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Show Data',
          ),
          BottomNavigationBarItem(
            icon: _homeScreenState.notificationCount > 0
                ? badges.Badge(
                    badgeContent: Text('${_homeScreenState.notificationCount}',
                        style: const TextStyle(
                          color: Colors.white,
                        )),
                    child: const Icon(Icons.save),
                  )
                : const Icon(Icons.save),
            label: 'Saved Data',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        selectedIconTheme: const IconThemeData(color: Colors.red),
        unselectedIconTheme: const IconThemeData(color: Colors.grey),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
