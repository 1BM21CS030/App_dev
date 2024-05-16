// ignore_for_file: library_private_types_in_public_api, empty_catches, file_names, non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Monitor/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
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
    if (kIsWeb) {
      pageDecider();
    }
  }

  Widget pageDecider() {
    if (navBar.selected == 0) {
      return const DeanHomePage();
    } else if (navBar.selected == 1) {
      return const DeanEditPage();
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
                        label: const Text('Upload',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)))),
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            navBar.selected = 2;
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
                  navBar.selected = page;
                });
              },
              children: pages),
      bottomNavigationBar: kIsWeb
          ? const SizedBox()
          : navBar(
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
        if (temp['Convener'] == null) {
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

  Future<void> download() async {
    final workbook = xls.Workbook();
    final worksheet = workbook.worksheets[0];
    List<String> keys = [
      'Date',
      'Department',
      'Time',
      'Class',
      'Faculty',
      'Course',
      'Room'
    ];
    for (int i = 1; i < keys.length + 1; i++) {
      worksheet.getRangeByIndex(1, i).setText(keys[i - 1]);
    }
    DateTime d = date.selected;
    if (freqReport.freq == 'Weekly') {
      d = date.selected.subtract(const Duration(days: 7));
    } else if (freqReport.freq == 'Monthly') {
      d = date.selected.subtract(const Duration(days: 30));
    } else if (freqReport.freq == 'Quaterly') {
      d = date.selected.subtract(const Duration(days: 90));
    }
    List<String> depts = [];
    if (dropdown.selected == 'All Departments') {
      depts = reports.sublist(1, reports.length);
    } else {
      depts = [dropdown.selected];
    }
    QuerySnapshot reps = await FirebaseFirestore.instance
        .collection('Reports')
        .where('Department', whereIn: depts)
        .where('Date',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(DateTime(d.year, d.month, d.day, 0, 0)))
        .where('Date',
            isLessThanOrEqualTo: Timestamp.fromDate(DateTime(date.selected.year,
                date.selected.month, date.selected.day, 23, 59)))
        .orderBy('Date', descending: true)
        .get();
    int row = 2;
    for (QueryDocumentSnapshot q in reps.docs) {
      int column = 1;
      Map<String, dynamic> temp = q.data() as Map<String, dynamic>;
      if (!temp.containsKey('Published')) {
        Timestamp t = temp['Date'];
        temp['Date'] = DateFormat('dd-MM-yyyy').format(t.toDate());
      }
      for (String key in keys) {
        worksheet.getRangeByIndex(row, column).setText(temp[key]);
        column++;
      }
      row++;
    }
    final bytes = workbook.saveAsStream();
    if (kIsWeb) {
      await FileSaver.instance.saveFile(
        name:
            '${dropdown.selected}_${freqReport.freq}_${date.selected.day}-${date.selected.month}-${date.selected.year}.xlsx',
        mimeType: MimeType.microsoftExcel,
        bytes: Uint8List.fromList(bytes),
      );
    } else {
      final directory = await FilePicker.platform.getDirectoryPath();
      if (directory == null) {
        errorFunc(context, 'Invalid Folder',
            'Unable to access folder to download file.');
      } else {
        final path =
            '$directory/${dropdown.selected}_${freqReport.freq}_${date.selected.day}-${date.selected.month}-${date.selected.year}.xlsx';
        final file = File(path);

        await file.writeAsBytes(bytes);
      }
    }
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
      ))),
      Padding(
          padding: const EdgeInsets.all(15),
          child: ElevatedButton(
              onPressed: download,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text(
                'Download',
                style: TextStyle(color: Colors.white, fontSize: 18),
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
        logo(),
        uploadBox(title: 'Team List'),
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
  String name = '';
  String email = '';

  Future<void> getData() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    name = name_format(s.getString('name') as String);
    email = s.getString('email') as String;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
              child: FutureBuilder<void>(
                  future: getData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Center(
                            child: logo(),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.black, width: 2),
                                  ),
                                  child: Material(
                                    elevation: 2,
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ))),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.black, width: 2)),
                                  child: Material(
                                    elevation: 2,
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      child: Text(
                                        email,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ))),
                          const Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                'Change Password',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              )),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: TextField(
                                controller: old_pass,
                                decoration: const InputDecoration(
                                  labelText: 'Current Password',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2.0),
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
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2.0),
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
                            onPressed:
                                _isChangingPassword ? null : _changePassword,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black),
                            child: _isChangingPassword
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : const Text(
                                    'Change Password',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                          const SizedBox(height: 50),
                          kIsWeb
                              ? const SizedBox()
                              : ElevatedButton(
                                  onPressed: () async {
                                    final SharedPreferences s =
                                        await SharedPreferences.getInstance();
                                    s.remove('access');
                                    s.remove('name');
                                    s.remove('email');
                                    s.setBool('loggedIn', false);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SignInScreen()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black),
                                  child: const Text(
                                    'Sign Out',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                        ],
                      );
                    }
                  }))),
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
