// ignore_for_file: file_names, unused_import, camel_case_types, library_private_types_in_public_api, must_be_immutable, no_logic_in_create_state, use_build_context_synchronously, non_constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'package:file_saver/file_saver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:csv/csv.dart';
import 'package:Monitor/TeamApp.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as e;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;

class logo extends StatelessWidget {
  const logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            height: 200,
            width: 200,
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient:
                    RadialGradient(colors: [Colors.lightBlue, Colors.white])),
            child: Image.asset(
              'images/logo-modified.png',
            )));
  }
}

class freqReport extends StatefulWidget {
  static String freq = 'Daily';
  const freqReport({super.key});

  @override
  _freqReport createState() => _freqReport();
}

class _freqReport extends State<freqReport> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(6),
        child: Container(
          height: 45,
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black, width: 2)),
          child: Row(children: [
            Expanded(
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selected = 0;
                        freqReport.freq = 'Daily';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            selected == 0 ? Colors.white : Colors.black),
                    child: Text(
                      'Daily',
                      style: TextStyle(
                          color: selected == 0 ? Colors.black : Colors.white,
                          fontSize: 18),
                    ))),
            Expanded(
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selected = 1;
                        freqReport.freq = 'Weekly';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            selected == 1 ? Colors.white : Colors.black),
                    child: Text(
                      'Weekly',
                      style: TextStyle(
                          color: selected == 1 ? Colors.black : Colors.white,
                          fontSize: 18),
                    ))),
            Expanded(
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selected = 2;
                        freqReport.freq = 'Monthly';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            selected == 2 ? Colors.white : Colors.black),
                    child: Text(
                      'Monthly',
                      style: TextStyle(
                          color: selected == 2 ? Colors.black : Colors.white,
                          fontSize: 18),
                    ))),
            kIsWeb
                ? Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selected = 3;
                            freqReport.freq = 'Quaterly';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                selected == 3 ? Colors.white : Colors.black),
                        child: Text(
                          'Quaterly',
                          style: TextStyle(
                              color:
                                  selected == 3 ? Colors.black : Colors.white,
                              fontSize: 18),
                        )))
                : const Text('')
          ]),
        ));
  }
}

class date extends StatefulWidget {
  static DateTime selected = DateTime.now();
  const date({super.key});

  @override
  _date createState() => _date();
}

class _date extends State<date> {
  Future<void> _selected(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: date.selected,
        firstDate: DateTime(2020),
        lastDate: DateTime(2025));

    if (picked != null && picked != date.selected) {
      setState(() {
        if (picked.compareTo(DateTime.now()) > 0) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text(
                    'Future date selected',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  titlePadding: const EdgeInsets.all(10),
                  content: const Text('Please choose a date prior to today.',
                      style: TextStyle(fontSize: 18)),
                  contentPadding: const EdgeInsets.all(10),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    )
                  ],
                );
              });
        } else {
          date.selected = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(6),
        child: Container(
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.black, width: 2)),
            height: 45,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                      onTap: () => _selected(context),
                      child: const Icon(Icons.calendar_today,
                          color: Colors.white)),
                  const SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: () => _selected(context),
                      child: Text(
                          DateFormat('dd-MM-yyyy').format(date.selected),
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black)))
                ])));
  }
}

class dropdown extends StatefulWidget {
  List<String> reports;
  ValueChanged<String> onChanged;
  static String selected = '';
  dropdown(
      {super.key,
      required this.reports,
      required select,
      required this.onChanged}) {
    dropdown.selected = select;
  }

  @override
  _dropdown createState() => _dropdown();
}

class _dropdown extends State<dropdown> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(6),
        child: Container(
            padding: const EdgeInsets.all(10),
            height: 45,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.black, width: 2)),
            child: DropdownButton(
              isExpanded: true,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              iconSize: 18,
              value: dropdown.selected,
              onChanged: (String? newSel) {
                setState(() {
                  dropdown.selected = newSel!;
                  widget.onChanged(dropdown.selected);
                });
              },
              items: widget.reports.map((String option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(
                    option,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            )));
  }
}

class report extends StatelessWidget {
  final int access;
  final String title;
  const report({super.key, required this.title, required this.access});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(6),
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: GestureDetector(
                        onTap: () {
                          if (access == 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Details(dept: title)),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => reportage(dept: title)),
                            );
                          }
                        },
                        child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              title,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                            )))),
                IconButton(
                    onPressed: () {
                      if (access == 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Details(dept: title)),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => reportage(dept: title)),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_right,
                      color: Colors.black,
                    ))
              ],
            )));
  }
}

class navBar extends StatefulWidget {
  static int selected = 0;
  final Function(int) tabSelected;
  const navBar({super.key, required this.tabSelected});
  @override
  _navBar createState() => _navBar();
}

class _navBar extends State<navBar> {
  Widget navButtons(int num) {
    var x = Icons.home;
    switch (num) {
      case 0:
        x = Icons.home;
        break;
      case 1:
        x = Icons.edit;
        break;
      case 2:
        x = Icons.person;
        break;
    }
    return Container(
        decoration: BoxDecoration(
            color: navBar.selected == num
                ? const Color.fromARGB(255, 185, 185, 185)
                : Colors.white,
            border: Border.all(
                color: navBar.selected == num ? Colors.black : Colors.grey,
                width: 1),
            borderRadius: BorderRadius.circular(10)),
        child: GestureDetector(
          onTap: () {
            setState(() {
              navBar.selected = num;
            });
            widget.tabSelected(num);
          },
          child: Icon(x,
              size: 45,
              color: navBar.selected == num ? Colors.black : Colors.grey),
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
          children: [navButtons(0), navButtons(1), navButtons(2)],
        ));
  }
}

class uploadBox extends StatefulWidget {
  final String title;
  const uploadBox({super.key, required this.title});
  @override
  _uploadBox createState() => _uploadBox();
}

class _uploadBox extends State<uploadBox> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(6),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      widget.title,
                      style: const TextStyle(fontSize: 24, color: Colors.black),
                    ))
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Padding(
                    padding: const EdgeInsets.all(6),
                    child: _isUploading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _isUploading = true;
                              });

                              // Perform the upload operation here
                              await pickfile(context, widget.title);

                              setState(() {
                                _isUploading = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black),
                            child: const Text(
                              'Upload',
                              style:
                                  TextStyle(fontSize: 17, color: Colors.white),
                            ))),
                Padding(
                    padding: const EdgeInsets.all(6),
                    child: ElevatedButton(
                        onPressed: () async {
                          formatDownload(widget.title);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black),
                        child: const Text(
                          'Download',
                          style: TextStyle(fontSize: 17, color: Colors.white),
                        )))
              ]),
            ],
          ),
        ));
  }

  Future<void> formatDownload(String title) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final workbook = xls.Workbook();
    final worksheet = workbook.worksheets[0];
    switch (title) {
      case 'Faculty List':
        List keys = ['Serial No', 'Name', 'Email', 'Code'];
        for (int i = 1; i < keys.length + 1; i++) {
          worksheet.getRangeByIndex(1, i).setText(keys[i - 1]);
        }

        QuerySnapshot faculty = await FirebaseFirestore.instance
            .collection('DeptList')
            .doc(name_format(prefs.getString('name')!))
            .collection('Faculty')
            .get();
        int row = 2;
        for (QueryDocumentSnapshot doc in faculty.docs) {
          Map<String, dynamic> temp = doc.data() as Map<String, dynamic>;

          worksheet.getRangeByIndex(row, 1).setNumber(row - 1 as double?);
          worksheet.getRangeByIndex(row, 2).setText(temp['Name']);
          worksheet.getRangeByIndex(row, 3).setText(doc.id);
          worksheet.getRangeByIndex(row, 4).setText(temp['Code']);
          row++;
        }
        break;
      case 'Course List':
        List keys = ['Serial No', 'Course Code', 'Course Name'];
        for (int i = 1; i < keys.length + 1; i++) {
          worksheet.getRangeByIndex(1, i).setText(keys[i - 1]);
        }
        break;
      case 'Time Table':
        List days = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday'
        ];
        List times = [
          '8:00-8:55',
          '8:55-9:50',
          '9:50-10:45',
          '11:15-12:10',
          '12:10-1:05',
          '2:00-2:55',
          '2:55-3:50'
        ];
        int row = 1;

        for (int i = 0; i < 20; i++) {
          worksheet.getRangeByIndex(row, 1).setText('<Class>');
          worksheet.getRangeByIndex(row, 2).setText('<Class Room>');
          row++;
          for (int column = 2; column < times.length + 2; column++) {
            worksheet.getRangeByIndex(row, column).setText(times[column - 2]);
          }
          row++;
          days.forEach((day) {
            worksheet.getRangeByIndex(row, 1).setText(day);
            row++;
          });
          row++;
        }
        break;
      case 'Team List':
        List keys = [
          'Serial No',
          'Department',
          'Point of Contact',
          'Convener',
          'Team Member',
          'Team Member',
          'Team Member',
          'Team Member',
          'Team Member'
        ];
        for (int i = 1; i < keys.length + 1; i++) {
          worksheet.getRangeByIndex(1, i).setText(keys[i - 1]);
        }
        QuerySnapshot temp =
            await FirebaseFirestore.instance.collection('DeptList').get();
        int row = 2;
        for (QueryDocumentSnapshot doc in temp.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          worksheet.getRangeByIndex(row, 1).setNumber(row - 1 as double?);
          worksheet.getRangeByIndex(row, 2).setText(doc.id);
          worksheet.getRangeByIndex(row, 3).setText(data['Contact']);
          worksheet.getRangeByIndex(row, 4).setText(data['Convener']);
          int col = 5;
          doc['Members'].forEach((member) {
            worksheet.getRangeByIndex(row, col).setText(member);
            col++;
          });
          row++;
        }
        break;
    }
    final bytes = workbook.saveAsStream();
    if (kIsWeb) {
      await FileSaver.instance.saveFile(
        name: '${title}_${prefs.getString('name')}.xlsx',
        mimeType: MimeType.microsoftExcel,
        bytes: Uint8List.fromList(bytes),
      );
    } else {
      final directory = await FilePicker.platform.getDirectoryPath();
      if (directory == null) {
        errorFunc(context, 'Invalid Folder',
            'Unable to access folder to download file.');
      } else {
        final path = '$directory/${title}_${prefs.getString('name')}.xlsx';
        final file = File(path);

        await file.writeAsBytes(bytes);
      }
    }
  }
}

Future<void> pickfile(BuildContext context, String title) async {
  FilePickerResult? path = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
      allowMultiple: false,
      withData: true);

  if (path != null && path.files.isNotEmpty) {
    PlatformFile file = path.files.single;
    Uint8List fileBytes = file.bytes!;
    String fileName = file.name.split('.').first;
    await parser(context, fileName, fileBytes, title);
  } else {
    errorFunc(context, 'Invalid FileType', 'Please choose an excel file.');
  }
}

Future<void> team(BuildContext context) async {
  List<String> valid_users = [
    'dean.academic@bmsce.ac.in',
    'principal@bmsce.ac.in'
  ];
  List<String> convener = [];
  List<String> member = [];

  await FirebaseFirestore.instance
      .collection('Team')
      .doc('dean.academic@bmsce.ac.in')
      .set(
          {'access': '2', 'Name': 'Dean of Academic'}, SetOptions(merge: true));
  _signup(context, 'dean.academic@bmsce.ac.in');

  await FirebaseFirestore.instance
      .collection('Team')
      .doc('principal@bmsce.ac.in')
      .set({'access': '2', 'Name': 'Principal'}, SetOptions(merge: true));
  _signup(context, 'principal@bmsce.ac.in');

  QuerySnapshot<Map<String, dynamic>> signup = await FirebaseFirestore.instance
      .collection('DeptList')
      .where('Faculty')
      .get();

  for (QueryDocumentSnapshot q in signup.docs) {
    Map<String, dynamic> temp = q.data() as Map<String, dynamic>;
    convener.add(temp['Convener'].toString());
    member.addAll((temp['Members'] as List<dynamic>)
        .map((item) => item.toString())
        .toList());
  }
  convener = convener.toSet().toList();
  member = member.toSet().toList();

  try {
    for (String name in convener) {
      for (DocumentSnapshot doc in signup.docs) {
        QuerySnapshot faculty = await doc.reference
            .collection('Faculty')
            .where('Name', isEqualTo: name)
            .get();

        for (DocumentSnapshot email in faculty.docs) {
          valid_users.add(email.id);
          Map<String, dynamic> data = email.data() as Map<String, dynamic>;
          await FirebaseFirestore.instance.collection('Team').doc(email.id).set(
              {'access': '1', 'Name': data['Name']}, SetOptions(merge: true));
          _signup(context, email.id);
        }
      }
    }
    for (String name in member) {
      for (DocumentSnapshot doc in signup.docs) {
        QuerySnapshot faculty = await doc.reference
            .collection('Faculty')
            .where('Name', isEqualTo: name)
            .get();

        for (DocumentSnapshot email in faculty.docs) {
          valid_users.add(email.id);
          Map<String, dynamic> data = email.data() as Map<String, dynamic>;
          await FirebaseFirestore.instance.collection('Team').doc(email.id).set(
              {'access': '0', 'Name': data['Name']}, SetOptions(merge: true));
          _signup(context, email.id);
        }
      }
    }
    CollectionReference team = FirebaseFirestore.instance.collection('Team');
    QuerySnapshot update = await team.get();
    for (QueryDocumentSnapshot email in update.docs) {
      if (!valid_users.contains(email.id) && email['access'] != '3') {
        await team.doc(email.id).delete();
      }
    }
  } catch (e) {
    errorFunc(context, 'Error', 'Unable to read data from database.');
  }
}

Future<void> _signup(BuildContext context, String email) async {
  final FirebaseAuth auth = FirebaseAuth.instance;

  try {
    await auth.createUserWithEmailAndPassword(
        email: email, password: '1@BMSCE');
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {}
  } catch (e) {
    errorFunc(context, 'Error', 'Unable to onboard user.');
  }
}

String name_format(String str) {
  str = str.toLowerCase().replaceAll('.', ' ').replaceAll('  ', ' ').trim();
  String formatted = '';
  formatted += str[0].toUpperCase();
  for (int i = 1; i < str.length; i++) {
    if (str[i - 1] == ' ') {
      formatted += str[i].toUpperCase();
    } else {
      formatted += str[i];
    }
  }

  return formatted.replaceAll(' And ', ' and ').replaceAll(' Of ', ' of ');
}

Future<void> deleteSubCollection(
    CollectionReference parent, String temp) async {
  List<String> time = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  DocumentReference snapshot = parent.doc(temp);
  for (String t in time) {
    for (QueryDocumentSnapshot d in (await snapshot.collection(t).get()).docs) {
      d.reference.delete();
    }
  }
}

Future<void> parser(BuildContext context, String fileName, Uint8List fileBytes,
    String title) async {
  var collName = '';
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  switch (title) {
    case "Team List":
      collName = 'DeptList';
      break;
    case "Faculty List":
      collName = "DeptList";
      break;
    case "Course List":
      collName = prefs.getString('name')!;
      break;
    case "Time Table":
      collName = prefs.getString('name')!;
      break;
  }
  var excel = e.Excel.decodeBytes(fileBytes);

  CollectionReference collection =
      FirebaseFirestore.instance.collection(collName);

  if (title == 'Team List') {
    QuerySnapshot querySnapshot = await collection.get();
    for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
      await documentSnapshot.reference.delete();
    }
    try {
      for (var table in excel.tables.keys) {
        for (var rowIndex = 1;
            rowIndex < excel.tables[table]!.maxRows;
            rowIndex++) {
          var row = excel.tables[table]!.rows[rowIndex];

          if ((row[0] == null || row[0]!.value == null) &&
              (row[1] == null || row[1]!.value == null) &&
              (row[2] == null || row[2]!.value == null)) {
            continue;
          }

          DocumentReference doc =
              collection.doc(name_format(row[1]!.value.toString()));

          List<String> member = [];
          for (var i = 4; i < excel.tables[table]!.maxColumns; i++) {
            if (row[3] == null ||
                row[i] == null ||
                (row[i] != null &&
                    (row[i]?.value == null ||
                        row[i]?.value.toString() == 'Null'))) {
              continue;
            }

            member.add(name_format(row[i]!.value.toString()));
          }

          await FirebaseFirestore.instance
              .collection('Team')
              .doc(row[2]!.value.toString().trim())
              .set({
            'access': '3',
            'Name': row[1]!.value.toString().trim().toLowerCase()
          }, SetOptions(merge: true));
          _signup(context, row[2]!.value.toString().trim());

          await doc.set({
            'Members': member,
            'Convener': row[3] == null || row[3]!.value == null
                ? null
                : name_format(row[3]!.value.toString()),
            'Contact': row[2]!.value.toString()
          });
        }
      }
      team(context);

      errorFunc(context, 'Successful read', 'Data has been registered');
    } catch (e) {
      errorFunc(context, 'Error read', 'Please ensure format of excel sheet.');
    }
  } else if (title == "Faculty List") {
    try {
      DocumentReference col =
          collection.doc(name_format(prefs.getString('name')!));
      QuerySnapshot faculty = await col.collection('Faculty').get();

      faculty.docs.forEach((doc) async {
        await doc.reference.delete();
      });
      await col.collection('Faculty').doc().delete();
      for (var table in excel.tables.keys) {
        for (var rowIndex = 1;
            rowIndex < excel.tables[table]!.maxRows;
            rowIndex++) {
          var row = excel.tables[table]!.rows[rowIndex];
          if (row[0] == null) {
            continue;
          }

          col.collection('Faculty').doc(row[2]!.value.toString().trim()).set({
            'Name': name_format(row[1]!.value.toString()),
            'Code': row[3]!.value.toString().trim()
          });
        }
      }
      team(context);
      errorFunc(context, 'Successful read', 'Data has been registered');
    } catch (e) {
      errorFunc(context, 'Error read', 'Please ensure format of excel sheet.');
    }
  } else if (title == 'Course List') {
    await collection.doc('Courses').delete();

    try {
      DocumentReference doc = collection.doc('Courses');
      for (var table in excel.tables.keys) {
        for (var rowIndex = 1;
            rowIndex < excel.tables[table]!.maxRows;
            rowIndex++) {
          var row = excel.tables[table]!.rows[rowIndex];
          if (row[0] == null || row[0]?.value == null) continue;
          Map<String, String> data = {
            row[1]!.value.toString(): row[2]!.value.toString()
          };
          doc.set(data, SetOptions(merge: true));
        }
      }
      errorFunc(context, 'Successful read', 'Data has been registered');
    } catch (e) {
      errorFunc(context, 'Error read', 'Please ensure format of excel sheet.');
    }
  } else if (title == 'Time Table') {
    QuerySnapshot temp = await collection.get();

    for (QueryDocumentSnapshot q in temp.docs) {
      if (q.id.toString() != 'Courses') {
        await deleteSubCollection(collection, q.id);

        await q.reference.delete();
      }
    }

    try {
      for (var table in excel.tables.keys) {
        for (var rowIndex = 0;
            rowIndex < excel.tables[table]!.maxRows - 1;
            rowIndex = rowIndex + 8) {
          var row = excel.tables[table]!.rows[rowIndex];
          if (row[0] == null && row[1] == null) {
            rowIndex -= 7;
            continue;
          }
          if (((row[0] != null || row[0]!.value == null) &&
                  (row[1] != null || row[1]!.value == null)) ||
              (row[0]!.value.toString() == '<Class>' ||
                  row[1]!.value.toString() == '<Class Room>')) {
            String cls = row[0]!.value.toString();
            String room = row[1]!.value.toString();

            for (var i = 1; i < excel.tables[table]!.maxColumns; i++) {
              DocumentReference doc = collection.doc(
                  excel.tables[table]!.rows[rowIndex + 1][i]!.value.toString());
              doc.set({'type': 'active'});
              for (var j = rowIndex + 2; j < rowIndex + 7; j++) {
                if (excel.tables[table]!.rows[j][i] != null &&
                    excel.tables[table]!.rows[j][i]!.value != null) {
                  var elective = excel.tables[table]!.rows[j][i]!.value
                      .toString()
                      .split('/')
                      .toList();

                  CollectionReference coll = doc.collection(
                      excel.tables[table]!.rows[j][0]!.value.toString());

                  for (var e in elective) {
                    if (e.contains('(') && e.contains(')')) {
                      RegExp regExp =
                          RegExp(r'([A-Z0-9]+)-([A-Z]+)\(([A-Z0-9 ]+)\)');
                      Match? match = regExp.firstMatch(e);
                      if (match != null) {
                        coll.doc(match.group(3)!.toString()).set({
                          'Course': match.group(1)!.toString(),
                          'Faculty': match.group(2)!.toString(),
                          'Class': cls
                        }, SetOptions(merge: true));
                      }
                    } else {
                      RegExp regExp = RegExp(r'([A-Z0-9]+)-([A-Z]+)');
                      Match? match = regExp.firstMatch(e);
                      if (match != null) {
                        coll.doc(room).set({
                          'Course': match.group(1)!.toString(),
                          'Faculty': match.group(2)!.toString(),
                          'Class': cls
                        }, SetOptions(merge: true));
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      errorFunc(context, 'Successful read', 'Data has been registered');
    } catch (e) {
      errorFunc(context, 'Error read', 'Please ensure format of excel sheet.');
    }
  } else {
    errorFunc(
        context, 'Invalid FileType', 'Please select a valid excel sheet.');
  }
}

void errorFunc(BuildContext context, String title, String message) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          titlePadding: const EdgeInsets.all(10),
          content: Text(message, style: const TextStyle(fontSize: 18)),
          contentPadding: const EdgeInsets.all(10),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      });
}

class Details extends StatefulWidget {
  final String dept;
  const Details({super.key, required this.dept});
  @override
  _Details createState() => _Details();
}

class _Details extends State<Details> {
  List<Widget> report = [];
  Future<void>? fetch;
  @override
  void initState() {
    super.initState();
    fetch = getPublish();
  }

  Future<void> getPublish() async {
    List<Widget> reportList = [];
    DateTime d = date.selected;
    QuerySnapshot? reps;
    if (freqReport.freq == 'Weekly') {
      d = date.selected.subtract(const Duration(days: 7));
    } else if (freqReport.freq == 'Monthly') {
      d = date.selected.subtract(const Duration(days: 30));
    } else if (freqReport.freq == 'Quaterly') {
      d = date.selected.subtract(const Duration(days: 90));
    }

    try {
      reps = await FirebaseFirestore.instance
          .collection('Reports')
          .where('Department', isEqualTo: widget.dept)
          .where('Date',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(DateTime(d.year, d.month, d.day, 0, 0)))
          .where('Date',
              isLessThanOrEqualTo: Timestamp.fromDate(DateTime(
                  date.selected.year,
                  date.selected.month,
                  date.selected.day,
                  23,
                  59)))
          .orderBy('Date', descending: true)
          .get();
      for (QueryDocumentSnapshot q in reps.docs) {
        Map<String, dynamic> temp = q.data() as Map<String, dynamic>;
        if (!temp.containsKey('Published')) {
          Timestamp t = temp['Date'];
          temp['Date'] = DateFormat('dd-MM-yyyy').format(t.toDate());
          reportList.add(present(temp));
        }
      }

      setState(() {
        report = reportList;
      });
    } catch (e) {
      errorFunc(context, 'Request Failed', 'Failed to retrive data.');
    }
  }

  Widget present(Map<String, dynamic> temp) {
    // List<String> keys = ['Date', 'Time', 'Class', 'Faculty', 'Course', 'Room'];
    List<String> keys = ['Date', 'Time', 'Class', 'Faculty'];

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
                                text: temp[keys[index]],
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 20,
                                    color: Colors.red)),
                          ],
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ));
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
        body: Column(children: [
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
                          'No reports.\nAll classes have been handled.',
                          style: TextStyle(color: Colors.black, fontSize: 20),
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
                              })
                        ])));
                }
              })
        ]));
  }
}
