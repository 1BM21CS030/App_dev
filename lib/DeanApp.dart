// ignore_for_file: library_private_types_in_public_api, empty_catches, file_names, non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Monitor/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DeanComponents.dart';

class Dean extends StatefulWidget {
  const Dean({super.key});
  @override
  _Dean createState() => _Dean();
}

class _Dean extends State<Dean> {
  late PageController control;
  @override
  void initState() {
    super.initState();
    control = PageController(initialPage: navBar.selected);
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

  final List<Widget> pages = [
    const DeanHomePage(),
    const DeanEditPage(),
    const Profile()
  ];

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            color: Colors.black,
            height: 1.5,
          ),
        ),
      ),
      body: PageView(
          controller: control,
          onPageChanged: (int page) {
            setState(() {
              navBar.selected = page;
            });
          },
          children: pages),
      bottomNavigationBar: navBar(
        tabSelected: tabSelected,
      ),
    );
  }
}

class DeanHomePage extends StatefulWidget {
  const DeanHomePage({super.key});

  @override
  _DeanHomePage createState() => _DeanHomePage();
}

class _DeanHomePage extends State<DeanHomePage> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<String> reports = [];
  List<Widget> result = [];
  ValueNotifier<String> selectedValue =
      ValueNotifier<String>('All Departments');

  Future<void> _initializeData() async {
    reports.add("All Departments");
    await getDept('DeptList');
    depts();
    setState(() {});
  }

  Future<void> getDept(String collection) async {
    try {
      QuerySnapshot query =
          await FirebaseFirestore.instance.collection(collection).get();
      for (QueryDocumentSnapshot documentSnapshot in query.docs) {
        Map<String, dynamic> temp =
            documentSnapshot.data() as Map<String, dynamic>;
        if (temp['Convener'] == 'Null') {
          continue;
        }
        reports.add(documentSnapshot.id);
      }
    } catch (e) {}
  }

  void depts() {
    for (var r in reports) {
      result.add(report(
        title: r,
        access: 0,
      ));
    }
  }

  List<Widget> selector() {
    int selectedIndex = reports.indexOf(dropdown.selected);

    if (dropdown.selected == 'All Departments' && result.isNotEmpty) {
      return result.sublist(1, reports.length);
    } else if (selectedIndex >= 0 && selectedIndex < result.length) {
      return [result[selectedIndex]];
    } else {
      return [];
    }
  }

  void onDropdownChanged(String newSelection) {
    selectedValue.value = newSelection;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const logo(),
      const freqReport(),
      const date(),
      dropdown(
          reports: reports,
          select: 'All Departments',
          onChanged: onDropdownChanged),
      Expanded(
          child: SingleChildScrollView(
              child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ValueListenableBuilder<String>(
            valueListenable: selectedValue,
            builder: (context, value, child) {
              List<Widget> selectedWidgets = selector();
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedWidgets.length,
                itemBuilder: (context, index) {
                  return selectedWidgets[index];
                },
              );
            },
          )
        ],
      )))
    ]);
  }
}

class DeanEditPage extends StatelessWidget {
  const DeanEditPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        uploadBox(title: 'Team List'),
        uploadBox(title: 'Faculty List'),
        uploadBox(title: 'Course List'),
        uploadBox(title: 'Time Table'),
      ],
    ));
  }
}

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  _Profile createState() => _Profile();
}

class _Profile extends State<Profile> {
  final TextEditingController old_pass = TextEditingController();
  final TextEditingController new_pass = TextEditingController();
  bool _isChangingPassword = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(
                  child: logo(),
                ),
                const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Change Password',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 24),
                    )),
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: old_pass,
                      decoration: const InputDecoration(
                        labelText: 'Current Password',
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 2.0),
                        ),
                      ),
                      obscureText: true,
                    )),
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: new_pass,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 2.0),
                        ),
                      ),
                      obscureText: true,
                    )),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isChangingPassword ? null : _changePassword,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: _isChangingPassword
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Change Password',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () async {
                    final SharedPreferences s =
                        await SharedPreferences.getInstance();
                    s.remove('access');
                    s.remove('id');
                    s.setBool('loggedIn', false);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignInScreen()));
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _errorMessage = '';
  Future<void> _changePassword() async {
    setState(() {
      _errorMessage = '';
      _isChangingPassword = true;
    });
    try {
      User? user = _auth.currentUser;

      final AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: old_pass.text,
      );
      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(new_pass.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message!;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      setState(() {
        _isChangingPassword = false; // Set back to false after completion
      });
    }
  }
}
