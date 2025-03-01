import 'package:flutter/material.dart';

import '../pages/index.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: TabBarView(
          children: [
            HomePage(),
            OtherClientPage(),
            AppMorePage(),
          ],
        ),
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(
              text: 'Home',
              icon: Icon(Icons.home),
            ),
            Tab(
              text: 'Other Client',
              icon: Icon(Icons.person),
            ),
            Tab(
              text: 'More',
              icon: Icon(Icons.grid_view_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
