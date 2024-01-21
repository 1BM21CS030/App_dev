// ignore_for_file: file_names, unused_import, camel_case_types, library_private_types_in_public_api, must_be_immutable, no_logic_in_create_state, use_build_context_synchronously

import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:fitbit_theme/TeamApp.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as e;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                    child: Text(option),
                  );
                }).toList(),
              ))
        ]));
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
                Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    )),
                IconButton(
                    onPressed: () {
                      if (access == 0) {
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
      collName = "DeptList";
      break;
    case "Course List":
      collName = p.basenameWithoutExtension(filePath);
      break;
    case "Time Table":
      collName = p.basenameWithoutExtension(filePath);
      break;
  }
  var bytes = File(filePath).readAsBytesSync();
  var excel = e.Excel.decodeBytes(bytes);

  CollectionReference collection =
      FirebaseFirestore.instance.collection(collName);
  if (title == 'Department List') {
    for (var table in excel.tables.keys) {
      for (var rowIndex = 1;
          rowIndex < excel.tables[table]!.maxRows;
          rowIndex++) {
        var row = excel.tables[table]!.rows[rowIndex];
        DocumentReference doc = collection.doc(row[0]!.value.toString());
        await doc.set({
          'Members': row[2]!.value.toString().split(',').toList(),
          'Convener': row[1]!.value.toString()
        });
      }
    }
  } else if (title == "Faculty List") {
    Map<String, dynamic> data = {};
    for (var table in excel.tables.keys) {
      for (var rowIndex = 1;
          rowIndex < excel.tables[table]!.maxRows;
          rowIndex++) {
        var row = excel.tables[table]!.rows[rowIndex];
        if (!data.containsKey(row[3]!.value.toString())) {
          data[row[3]!.value.toString()] = {'Faculty': []};
        }
        data[row[3]!.value.toString()]['Faculty']!.add({
          "Name": row[0]!.value.toString(),
          'Email': row[1]!.value.toString(),
          'Code': row[2]!.value.toString()
        });
      }
    }
    for (var d in data.keys) {
      DocumentReference doc = collection.doc(d);
      await doc.update(data[d]);
    }
  } else if (title == 'Course List') {
    DocumentReference doc = collection.doc('Courses');
    for (var table in excel.tables.keys) {
      for (var rowIndex = 2;
          rowIndex < excel.tables[table]!.maxRows;
          rowIndex++) {
        var row = excel.tables[table]!.rows[rowIndex];
        Map<String, String> data = {
          row[1]!.value.toString(): row[0]!.value.toString()
        };
        doc.set(data, SetOptions(merge: true));
      }
    }
  } else if (title == 'Time Table') {
    for (var table in excel.tables.keys) {
      for (var rowIndex = 0;
          rowIndex < excel.tables[table]!.maxRows - 1;
          rowIndex = rowIndex + 8) {
        var row = excel.tables[table]!.rows[rowIndex];
        String cls = row[0]!.value.toString();
        String room = row[1]!.value.toString();

        for (var i = 1; i < excel.tables[table]!.maxColumns; i++) {
          DocumentReference doc = collection.doc(
              excel.tables[table]!.rows[rowIndex + 1][i]!.value.toString());
          Map<String, dynamic> data = {};

          for (var j = rowIndex + 2; j < rowIndex + 6; j++) {
            if (excel.tables[table]!.rows[j][i] != null &&
                excel.tables[table]!.rows[j][i]!.value != null) {
              var elective = excel.tables[table]!.rows[j][i]!.value
                  .toString()
                  .split('/')
                  .toList();

              for (var e in elective) {
                if (e.contains('()')) {
                  RegExp regExp = RegExp(r'([A-Z0-9]+)-([A-Z]+)\(([A-Z0-9])\)');
                  Match? match = regExp.firstMatch(e);

                  data[excel.tables[table]!.rows[j][0]!.value.toString()] = {
                    match!.group(3)!.toString(): {
                      'Course': match.group(1)!.toString(),
                      'Faculty': match.group(2)!.toString(),
                      'Class': cls
                    }
                  };
                } else {
                  RegExp regExp = RegExp(r'([A-Z0-9]+)-([A-Z]+)');
                  Match? match = regExp.firstMatch(e);

                  data[excel.tables[table]!.rows[j][0]!.value.toString()] = {
                    room: {
                      'Course': match!.group(1)!.toString(),
                      'Faculty': match.group(2)!.toString(),
                      'Class': cls
                    }
                  };
                }
              }

              await doc.set(data, SetOptions(merge: true));
            }
          }
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
