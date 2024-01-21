// ignore_for_file: library_private_types_in_public_api, empty_catches, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'DeanComponents.dart';

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
      Expanded(
          child: SingleChildScrollView(
              child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const freqReport(),
          const date(),
          dropdown(
              reports: reports,
              select: 'All Departments',
              onChanged: onDropdownChanged),
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
