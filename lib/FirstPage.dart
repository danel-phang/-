import 'package:flutter/material.dart';
import 'package:republic/Discipline.dart';
import 'package:republic/History.dart';
import 'Story.dart';

class FifthPage extends StatefulWidget {
  const FifthPage({Key? key}) : super(key: key);

  @override
  _MainTabPageState createState() => _MainTabPageState();
}

class _MainTabPageState extends State<FifthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          height: 45,
          color: const Color.fromARGB(255, 255, 238, 238),
          child: SafeArea(
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color.fromARGB(255, 239, 42, 39),
              dividerColor: const Color.fromARGB(255, 255, 238, 238),
              labelColor: const Color.fromARGB(255, 239, 42, 39),
              unselectedLabelColor: const Color.fromARGB(179, 42, 42, 42),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              tabs: const [
                Tab(text: '学党史'),
                Tab(text: '学党纪'),
                Tab(text: '党纪小故事'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const History(),
          Discipline(),
          StoriesHomePage(),
        ],
      ),
    );
  }
}
