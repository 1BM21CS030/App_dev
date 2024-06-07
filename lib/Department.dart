// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:Monitor/DeanApp.dart';
import 'package:Monitor/TeamApp.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:Monitor/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DeanComponents.dart';

class Department extends StatefulWidget {
  const Department({super.key});
  @override
  _Department createState() => _Department();
}

class _Department extends State<Department> {
  late PageController control;
  @override
  void initState() {
    super.initState();
    control = PageController(initialPage: navBarTeam.selected);
    if (kIsWeb) pageDecider();
  }

  Widget pageDecider() {
    if (navBar.selected == 0) {
      return const DeptHomePage();
    } else {
      return const Profile();
    }
  }

  @override
  void dispose() {
    control.dispose();
    super.dispose();
  }

  void tabSelected(int index) {
    control.animateToPage(index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastEaseInToSlowEaseOut);
  }

  final List<Widget> pages = [const DeptHomePage(), const Profile()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Class Monitoring',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
            onPressed: () {}, icon: const Icon(Icons.monitor_rounded)),
        actions: kIsWeb
            ? [
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            navBar.selected = 0;
                          });
                        },
                        label: const Text(
                          'Home',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ))),
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            navBar.selected = 1;
                          });
                        },
                        label: const Text('Profile',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)))),
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextButton.icon(
                        onPressed: () async {
                          final SharedPreferences s =
                              await SharedPreferences.getInstance();
                          s.remove('access');
                          s.remove('name');
                          s.remove('email');
                          s.setBool('loggedIn', false);
                          Navigator.push(
                              // ignore: use_build_context_synchronously
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignInScreen()));
                        },
                        label: const Text('Sign Out',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black))))
              ]
            : [],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            color: Colors.black,
            height: 1.5,
          ),
        ),
      ),
      body: kIsWeb
          ? pageDecider()
          : PageView(
              controller: control,
              onPageChanged: (int page) {
                setState(() {
                  navBarTeam.selected = page;
                });
              },
              children: pages),
      bottomNavigationBar: kIsWeb
          ? const SizedBox()
          : navBarTeam(
              tabSelected: tabSelected,
            ),
    );
  }
}

class DeptHomePage extends StatefulWidget {
  const DeptHomePage({super.key});

  @override
  _DeptHomePage createState() => _DeptHomePage();
}

class _DeptHomePage extends State<DeptHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logo(),
        uploadBox(title: 'Faculty List'),
        uploadBox(title: 'Course List'),
        uploadBox(title: 'Time Table'),
      ],
    );
  }
}
