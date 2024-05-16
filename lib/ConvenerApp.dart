// ignore_for_file: library_private_types_in_public_api, file_names, camel_case_types, use_build_context_synchronously

import 'package:Monitor/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Monitor/TeamApp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DeanComponents.dart';
import 'DeanApp.dart';

class Convener extends StatefulWidget {
  const Convener({super.key});
  @override
  _Convener createState() => _Convener();
}

class _Convener extends State<Convener> {
  late PageController control;
  @override
  void initState() {
    super.initState();
    control = PageController(initialPage: navBar.selected);
    if (kIsWeb) pageDecider();
  }

  Widget pageDecider() {
    if (navBar.selected == 0) {
      return const TeamHomePage();
    } else if (navBar.selected == 1) {
      return const PublishPage();
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
    const TeamHomePage(),
    const PublishPage(),
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
                        label: const Text('Publish',
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

class PublishPage extends StatefulWidget {
  const PublishPage({super.key});
  @override
  _PublishPage createState() => _PublishPage();
}

class _PublishPage extends State<PublishPage> {
  List<Widget> report = [];
  Map<String, int> selectedReports = {};
  Future<void>? fetch;
  bool _submit = false;
  @override
  void initState() {
    super.initState();

    fetch = getPublish();
  }

  Future<void> getPublish() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    QuerySnapshot doc = await FirebaseFirestore.instance
        .collection('DeptList')
        .where('Convener', isEqualTo: s.getString('name'))
        .get();
    QuerySnapshot reps = await FirebaseFirestore.instance
        .collection('Reports')
        .where('Published', isEqualTo: false)
        .where('Department', whereIn: doc.docs.map((d) => d.id).toList())
        .get();
    for (QueryDocumentSnapshot q in reps.docs) {
      Map<String, dynamic> temp = q.data() as Map<String, dynamic>;
      Timestamp t = temp['Date'];
      temp['Date'] = DateFormat('dd-MM-yyyy').format(t.toDate());
      report.add(publishBox(
        temp: temp,
        id: q.id,
        onSelectedChange: (id, index) {
          selectedReports[id] = index;
        },
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      FutureBuilder<void>(
          future: fetch,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator()));
            } else {
              return report.isEmpty
                  ? const Expanded(
                      child: Center(
                          child: Text(
                      'No reports',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    )))
                  : Expanded(
                      child: SingleChildScrollView(
                          child: Column(children: [
                      ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: report.length,
                          itemBuilder: (context, index) {
                            return report[index];
                          }),
                      Padding(
                          padding: const EdgeInsets.all(16),
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _submit = true;
                              });
                              try {
                                for (String i in selectedReports.keys) {
                                  if (selectedReports[i] == 1) {
                                    await FirebaseFirestore.instance
                                        .collection('Reports')
                                        .doc(i)
                                        .delete();
                                  }
                                }
                                QuerySnapshot query = await FirebaseFirestore
                                    .instance
                                    .collection('Reports')
                                    .where('Published', isEqualTo: false)
                                    .get();
                                for (QueryDocumentSnapshot q in query.docs) {
                                  await FirebaseFirestore.instance
                                      .collection('Reports')
                                      .doc(q.id)
                                      .update(
                                          {'Published': FieldValue.delete()});
                                }
                              } catch (e) {
                                errorFunc(
                                    context, 'Error', 'Something went wrong.');
                              } finally {
                                setState(() {
                                  _submit = false;
                                });
                              }

                              errorFunc(context, 'Successful read',
                                  'Data is registered.');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                            ),
                            child: _submit
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : const Text(
                                    'Publish',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                          ))
                    ])));
            }
          }),
    ]);
  }
}

class publishBox extends StatefulWidget {
  final Map<String, dynamic> temp;
  final String id;
  final Function(String id, int selected) onSelectedChange;
  const publishBox(
      {super.key,
      required this.temp,
      required this.id,
      required this.onSelectedChange});
  @override
  _publishBox createState() => _publishBox();
}

class _publishBox extends State<publishBox> {
  int selected = 0;
  List<String> keys = [
    'Department',
    'Date',
    'Time',
    'Class',
    'Faculty',
    'Course',
    'Room'
  ];
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
            children: [
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: keys.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(
                              text: keys[index],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            const TextSpan(
                              text: ' : ',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal, fontSize: 20),
                            ),
                            TextSpan(
                                text: widget.temp[keys[index]],
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 20,
                                    color: Colors.red)),
                          ],
                        ),
                      ),
                    );
                  }),
              ToggleButtons(
                isSelected: [selected == 0, selected == 1],
                onPressed: (int index) {
                  setState(() {
                    selected = index;
                    widget.onSelectedChange(widget.id, selected);
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
                      'Publish',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Discard',
                      style: TextStyle(
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
