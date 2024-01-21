// ignore_for_file: library_private_types_in_public_api, empty_catches, non_constant_identifier_names, file_names, camel_case_types, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'DeanComponents.dart';
import 'DeanApp.dart';

String time = '8:00-8:55';
String Day = 'Monday';

class Team extends StatefulWidget {
  const Team({super.key});
  @override
  _Team createState() => _Team();
}

class _Team extends State<Team> {
  late PageController control;
  @override
  void initState() {
    super.initState();
    control = PageController(initialPage: navBarTeam.selected);
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

  final List<Widget> pages = [const TeamHomePage(), const Profile()];

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
              navBarTeam.selected = page;
            });
          },
          children: pages),
      bottomNavigationBar: navBarTeam(
        tabSelected: tabSelected,
      ),
    );
  }
}

class TeamHomePage extends StatefulWidget {
  const TeamHomePage({super.key});

  @override
  _TeamHomePage createState() => _TeamHomePage();
}

class _TeamHomePage extends State<TeamHomePage> {
  List<String> reports = [];
  List<Widget> result = [];
  List<String> cls_hours = [
    '8:00-8:55',
    '8:55-9:50',
    '9:50-10:45',
    '11:15-12:10',
    '12:10-1:05',
    '2:00-2:55',
    '2:55-3:50'
  ];
  String selected = '8:00-8:55';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await getDept('DeptList');
    depts();
    int hour = DateTime.now().hour;
    int minute = DateTime.now().minute;
    if (hour == 8 && minute > 0 && minute < 55) {
      selected = cls_hours[0];
    } else if ((hour == 8 && minute >= 55) || (hour == 9 && minute < 50)) {
      selected = cls_hours[1];
    } else if ((hour == 9 && minute > 50) || (hour == 10 && minute < 45)) {
      selected = cls_hours[2];
    } else if ((hour == 11 && minute > 15) || (hour == 12 && minute < 10)) {
      selected = cls_hours[3];
    } else if ((hour == 12 && minute > 10) || (hour == 1 && minute < 5)) {
      selected = cls_hours[4];
    } else if ((hour == 2) || (hour == 2 && minute < 50)) {
      selected = cls_hours[5];
    } else if ((hour == 2 && minute > 50) || (hour == 3 && minute < 55)) {
      selected = cls_hours[6];
    }
    setState(() {});
  }

  Future<void> getDept(String collection) async {
    try {
      QuerySnapshot query =
          await FirebaseFirestore.instance.collection(collection).get();
      for (QueryDocumentSnapshot documentSnapshot in query.docs) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        if (data['Convener'] == 'E' || data['Members'].contains('E')) {
          reports.add(documentSnapshot.id);
        }
      }
    } catch (e) {}
  }

  void depts() {
    for (var r in reports) {
      result.add(report(
        title: r,
        access: 1,
      ));
    }
  }

  void onDropdownChanged(String r) {
    dropdown.selected = r;
    selected = r;
    time = r;
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
            const date(),
            dropdown(
                reports: cls_hours,
                select: selected,
                onChanged: onDropdownChanged),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                return result[index];
              },
            )
          ],
        ),
      ))
    ]);
  }
}

class navBarTeam extends StatefulWidget {
  static int selected = 0;
  final Function(int) tabSelected;
  const navBarTeam({super.key, required this.tabSelected});
  @override
  _navBarTeam createState() => _navBarTeam();
}

class _navBarTeam extends State<navBarTeam> {
  Widget navButtons(int num) {
    var x = Icons.home;
    switch (num) {
      case 0:
        x = Icons.home;
        break;
      case 1:
        x = Icons.person;
        break;
    }
    return Container(
        decoration: BoxDecoration(
            color: navBarTeam.selected == num
                ? const Color.fromARGB(255, 185, 185, 185)
                : Colors.white,
            border: Border.all(
                color: navBarTeam.selected == num ? Colors.black : Colors.grey,
                width: 1),
            borderRadius: BorderRadius.circular(10)),
        child: GestureDetector(
          onTap: () {
            setState(() {
              navBarTeam.selected = num;
            });
            widget.tabSelected(num);
          },
          child: Icon(x,
              size: 45,
              color: navBarTeam.selected == num ? Colors.black : Colors.grey),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black, width: 1))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [navButtons(0), navButtons(1)],
        ));
  }
}

class reportage extends StatefulWidget {
  final String dept;
  const reportage({super.key, required this.dept});
  @override
  _reportage createState() => _reportage();
}

class _reportage extends State<reportage> {
  List<String> classes = [];
  Map<String, int> selectedRooms = {};
  @override
  void initState() {
    super.initState();
    initializeAsync();
  }

  Future<void> initializeAsync() async {
    await getClasses();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> getClasses() async {
    String day = '';
    switch (date.selected.weekday) {
      case DateTime.monday:
        day = 'Monday';
        break;
      case DateTime.tuesday:
        day = 'Tuesday';
        break;
      case DateTime.wednesday:
        day = 'Wednesday';
        break;
      case DateTime.thursday:
        day = 'Thursday';
        break;
      case DateTime.friday:
        day = 'Friday';
        break;
    }

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection(widget.dept)
        .doc(time)
        .get();
    Map<String, dynamic> temp = doc.data() as Map<String, dynamic>;
    if (temp[day] != null) {
      classes = (temp[day] as Map<String, dynamic>).keys.toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            color: Colors.black,
            height: 1.5,
          ),
        ),
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const logo(),
            Expanded(
                child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      return toggleBox(
                        room: classes[index],
                        onSelectedChange: (room, index) {
                          selectedRooms[room] = index;
                        },
                      );
                    })),
            Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () async {
                    Map<String, dynamic> data = {};
                    for (var i in selectedRooms.keys) {
                      if (selectedRooms[i] == 1) {
                        data = {
                          'Date': DateFormat('dd-Mm-yyyy')
                              .format(date.selected)
                              .toString(),
                          'Room': i,
                          'Time': dropdown.selected
                        };
                      }
                      if (data.isNotEmpty) {
                        DocumentReference doc = FirebaseFirestore.instance
                            .collection('Reports')
                            .doc(widget.dept);

                        await doc.set(
                            {const Uuid().v4(): data}, SetOptions(merge: true));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ))
          ]),
    );
  }
}

class toggleBox extends StatefulWidget {
  final String room;
  final Function(String room, int selected) onSelectedChange;
  const toggleBox(
      {super.key, required this.room, required this.onSelectedChange});
  @override
  _toggleBox createState() => _toggleBox();
}

class _toggleBox extends State<toggleBox> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.7),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 50,
                child: Text(
                  widget.room,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ToggleButtons(
                isSelected: [selected == 0, selected == 1],
                onPressed: (int index) {
                  setState(() {
                    selected = index;
                    widget.onSelectedChange(widget.room, selected);
                  });
                },
                borderRadius: BorderRadius.circular(8),
                selectedBorderColor: Colors.white,
                selectedColor: Colors.white,
                fillColor: Colors.black,
                color: Colors.black,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Yes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'No',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
