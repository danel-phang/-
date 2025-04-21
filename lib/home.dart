import 'package:flutter/material.dart';
import 'package:republic/FirstPage.dart';
import 'package:republic/FourthPage.dart';
import 'package:republic/ThirdPage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:republic/UserPage.dart';
import 'package:republic/LongMarch.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final widgets = [
    FifthPage(),
    ThirdPage(),
    FourthPage(),
    LongMarchApp(),
  ];
  int index = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 239, 42, 39),
          toolbarHeight: 48,
          elevation: 2,
          titleSpacing: 0,
          leading: Container(
            padding: const EdgeInsets.all(4.0),
            child: SvgPicture.asset(
              'assets/logo/logo.svg',
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              fit: BoxFit.contain,
            ),
          ),
          title: Container(
            height: 45,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
            child: TextField(
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: '搜索',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: const SizedBox(
                  width: 42,
                  child: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 239, 42, 39), width: 1.5),
                ),
              ),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 5),
              child: IconButton(
                icon: const Icon(Icons.person, color: Colors.white),
                // 点击跳转到个人中心
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UserPage()),
                  );
                },
              ),
            ),
          ],
        ),
        body: widgets[index],
        bottomNavigationBar: SizedBox(
          height: 64, // Set your desired height here
          child: BottomNavigationBar(
            currentIndex: index,
            selectedItemColor: const Color.fromARGB(255, 239, 42, 39),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            selectedFontSize: 10, // Smaller font size to reduce height
            unselectedFontSize: 10, // Smaller font size to reduce height
            iconSize: 24, // Adjust icon size as needed
            onTap: (index) {
              setState(() {
                this.index = index;
              });
            },
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book),
                label: '学习',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.format_paint),
                label: '趣党创',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.cabin_sharp),
                label: '知识竞赛',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.videogame_asset_outlined),
                label: '重走长征路',
              ),
            ],
          ),
        ));
  }
}
