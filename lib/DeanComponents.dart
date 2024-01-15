// ignore_for_file: file_names, unused_import, camel_case_types, library_private_types_in_public_api, must_be_immutable, no_logic_in_create_state, use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:excel/excel.dart' as e;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class logo extends StatefulWidget {
  const logo({super.key});
  @override
  _logo createState() => _logo();
}

class _logo extends State<logo> {
  List<Color> colors = [Colors.lightBlue, Colors.white];

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: colors)),
            child: Image.asset(
              'images/logo-modified.png',
            )));
  }
}

class freqReport extends StatefulWidget {
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
                    )))
          ]),
        ));
  }
}

class date extends StatefulWidget {
  const date({super.key});

  @override
  _date createState() => _date();
}

class _date extends State<date> {
  DateTime selected = DateTime.now();

  Future<void> _selected(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selected,
        firstDate: DateTime(2020),
        lastDate: DateTime(2025));

    if (picked != null && picked != selected) {
      setState(() {
        selected = picked;
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
                      child: Text('${selected.toLocal()}'.split(' ')[0],
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black)))
                ])));
  }
}

class dropdown extends StatefulWidget {
  List<String> reports;
  dropdown({super.key, required this.reports});

  @override
  _dropdown createState() => _dropdown(reports);
}

class _dropdown extends State<dropdown> {
  String selected = '';
  List<String> reports;
  _dropdown(this.reports);

  @override
  void initState() {
    super.initState();
    selected = reports.first;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(6),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              padding: const EdgeInsets.all(10),
              height: 45,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.black, width: 2)),
              child: DropdownButton(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                iconSize: 18,
                value: selected,
                onChanged: (String? newSel) {
                  setState(() {
                    selected = newSel!;
                  });
                },
                items: reports.map((String option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
              ))
        ]));
  }
}

class report extends StatelessWidget {
  final String title;
  const report({super.key, required this.title});

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
                Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    )),
                IconButton(
                    onPressed: () {},
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
              size: 40,
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

class uploadBox extends StatelessWidget {
  final String title;
  const uploadBox({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(6),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 1)),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 24, color: Colors.black),
                    ))
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Padding(
                    padding: const EdgeInsets.all(6),
                    child: ElevatedButton(
                        onPressed: () async {
                          pickfile(context, title);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black),
                        child: const Text(
                          'Upload',
                          style: TextStyle(fontSize: 17, color: Colors.white),
                        )))
              ])
            ],
          ),
        ));
  }
}

class uploadBoxTT extends StatefulWidget {
  final String title;
  static String room = '';
  const uploadBoxTT({super.key, required this.title});
  @override
  _uploadBoxTT createState() => _uploadBoxTT(title: title);
}

class _uploadBoxTT extends State<uploadBoxTT> {
  final String title;

  TextEditingController control = TextEditingController();
  _uploadBoxTT({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(6),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 1)),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 24, color: Colors.black),
                    ))
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: TextField(
                            controller: control,
                            decoration: const InputDecoration(
                              labelText: 'Room Number',
                              border: OutlineInputBorder(),
                            )))),
                Padding(
                    padding: const EdgeInsets.all(6),
                    child: ElevatedButton(
                        onPressed: () {
                          uploadBoxTT.room = control.text;

                          pickfile(context, title);
                          control.clear();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black),
                        child: const Text(
                          'Upload',
                          style: TextStyle(fontSize: 17, color: Colors.white),
                        )))
              ])
            ],
          ),
        ));
  }
}

Future<void> pickfile(BuildContext context, String title) async {
  FilePickerResult? path = await FilePicker.platform.pickFiles();
  if (path != null) {
    File file = File(path.files.single.path!);
    String temp = file.path;
    String extension = p.extension(temp);
    if (extension == '.xls' || extension == '.xlsx') {
      await parser(context, temp, title);
    }
  } else {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Invalid FileType',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            titlePadding: const EdgeInsets.all(10),
            content: const Text('Please choose an Excel file.',
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
  }
}

Future<void> parser(BuildContext context, String filePath, String title) async {
  var collName = '';
  switch (title) {
    case "Department List":
      collName = 'DeptList';
      break;
    case "Faculty List":
      collName = "FacultyList";
      break;
    case "Team List":
      collName = "TeamList";
      break;
    case "Time Table":
      collName = "timeTable";
      break;
  }
  var bytes = File(filePath).readAsBytesSync();
  var excel = e.Excel.decodeBytes(bytes);
  // await Firebase.initializeApp();

  CollectionReference collection =
      FirebaseFirestore.instance.collection(collName);
  if (title == 'Department List') {
    for (var table in excel.tables.keys) {
      for (var rowIndex = 0;
          rowIndex < excel.tables[table]!.maxRows;
          rowIndex++) {
        if (rowIndex != 0) {
          var row = excel.tables[table]!.rows[rowIndex];
          DocumentReference docReference =
              collection.doc(row[0]!.value.toString());
          await docReference.set({
            'Rooms': row[1]!.value.toString().split(','),
            'Convener': row[2]!.value.toString()
          });
        }
      }
    }
  } else if (title == "Team List" || title == "Faculty List") {
    var id = (title == "Team List") ? 'Members' : 'Email';
    for (var table in excel.tables.keys) {
      for (var rowIndex = 0;
          rowIndex < excel.tables[table]!.maxRows;
          rowIndex++) {
        if (rowIndex != 0) {
          var row = excel.tables[table]!.rows[rowIndex];
          DocumentReference docReference =
              collection.doc(row[0]!.value.toString());
          await docReference.set({id: row[1]!.value.toString().split(',')});
        }
      }
    }
  } else if (title == 'Time Table') {
    if (uploadBoxTT.room != '') {
      DocumentReference docReference = collection.doc(uploadBoxTT.room);

      for (var table in excel.tables.keys) {
        var column = excel.tables[table]!.rows.first;
        for (var rowIndex = 1;
            rowIndex < excel.tables[table]!.maxRows;
            rowIndex++) {
          var data = {};
          var row = excel.tables[table]!.rows[rowIndex];
          for (var colnum = 1;
              colnum < excel.tables[table]!.maxColumns;
              colnum++) {
            if (row[colnum] != null) {
              data[column[colnum]!.value!.toString()] =
                  row[colnum]!.value?.toString();
            }
          }
          if (row[0] != null && row[0]!.value != null) {
            await docReference
                .set({row[0]!.value.toString(): data}, SetOptions(merge: true));
          }
        }
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Invalid Room Number',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              titlePadding: const EdgeInsets.all(10),
              content: const Text('Please enter a valid room.',
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
    }
  }
}
