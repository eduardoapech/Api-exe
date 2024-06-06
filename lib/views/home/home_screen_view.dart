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
  int _savedUserCount = 0; // Contador de usuários salvos
  int _savedDataCount = 0;

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
      _pageController.jumpToPage(index);
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
            onUserSaved: _incrementSavedUserCount, // Passando a função para a página ShowDataPage
          ),
          const SavedDataPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Show Data',
          ),
          BottomNavigationBarItem(
            icon: _savedDataCount > 0
                ? badges.Badge(
                    badgeContent: Text('$_savedDataCount',
                        style: const TextStyle(
                          color: Colors.white,
                        )),
                    child: const Icon(Icons.save),
                  )
                : const Icon(Icons.save),
            label: 'Saved Data',
          ),
        ],
        selectedItemColor: Colors.blue, // Cor do item selecionado
        unselectedItemColor: Colors.grey, // Cor do item não selecionado
        backgroundColor: Colors.white, // Cor de fundo da BottomNavigationBar
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
