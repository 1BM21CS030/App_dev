// ignore_for_file: must_be_immutable, library_private_types_in_public_api

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
    DeanHomePage(),
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

class DeanHomePage extends StatelessWidget {
  List<String> reports = [
    'Computer Science and Engineering',
    'Information Science and Engineering',
    'Artificial Intelligence',
    'Electronics and Communication',
    'Medical Electronics'
  ];
  DeanHomePage({super.key});
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
          dropdown(reports: reports),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reports.length,
            itemBuilder: ((context, index) {
              return report(
                title: reports[index],
              );
            }),
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
        uploadBox(title: 'Team List'),
        uploadBoxTT(title: 'Time Table')
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
