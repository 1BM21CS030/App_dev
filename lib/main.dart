// ignore_for_file: must_be_immutable, library_private_types_in_public_api, empty_catches, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'DeanComponents.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(
  //     options: const FirebaseOptions(
  //         apiKey: "AIzaSyCUNXZmkskCz4R3ftVd2Neh4Ngmb_EhDyQ",
  //         appId: "1:293421021076:web:05188c9d726ee773bc8181",
  //         messagingSenderId: "293421021076",
  //         projectId: "monitor-bmsce"));

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(213, 58, 104, 183)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
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
          'Monitor BMSCE',
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
  List<String> reports = [];
  List<Widget> result = [];
  ValueNotifier<String> selectedValue =
      ValueNotifier<String>('All Departments');
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

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
        reports.add(documentSnapshot.id);
      }
    } catch (e) {}
  }

  void depts() {
    for (var r in reports) {
      result.add(report(
        title: r,
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
      Expanded(
          child: SingleChildScrollView(
              child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const freqReport(),
          const date(),
          dropdown(reports: reports, onChanged: onDropdownChanged),
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
        uploadBox(title: 'Department List'),
        uploadBox(title: 'Faculty List'),
        uploadBox(title: 'Course List'),
        uploadBox(title: 'Time Table')
      ],
    ));
  }
}

class Profile extends StatelessWidget {
  const Profile({super.key});
  @override
  Widget build(BuildContext context) {
    return const Text('Profile');
  }
}
