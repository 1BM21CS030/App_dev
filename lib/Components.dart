// ignore_for_file: file_names, camel_case_types

import 'package:flutter/material.dart';

class Frame extends StatelessWidget {
  const Frame({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
      colors: [Color(0xFF008F98), Color(0xFF4CAF50)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )));
  }
}

class boxButton extends StatelessWidget {
  final String text;
  const boxButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      width: 275,
      height: 135,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 26,
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 79, 165, 82),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Upload",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class boxButtonTT extends StatelessWidget {
  final String text;
  const boxButtonTT({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      width: 275,
      height: 135,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 26,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.all(6),
                  child: SizedBox(
                    width: 25,
                    height: 50,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Room no',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 79, 165, 82),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Upload",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class navBarDean extends StatefulWidget {
  const navBarDean({super.key});

  @override
  navStateDean createState() => navStateDean();
}

class navStateDean extends State<navBarDean> {
  final PageController navControl = PageController();
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 60,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.blue, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black,
          iconSize: 25,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.edit), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '')
          ],
          onTap: (index) {
            navControl.animateToPage(index,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut);
          },
        ));
  }
}
