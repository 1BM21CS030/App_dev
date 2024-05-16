// ignore_for_file: must_be_immutable, library_private_types_in_public_api, empty_catches, non_constant_identifier_names, camel_case_types, use_build_context_synchronously

import 'dart:async';
import 'package:Monitor/Department.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Monitor/DeanComponents.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'TeamApp.dart';
import 'DeanApp.dart';
import 'ConvenerApp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCUNXZmkskCz4R3ftVd2Neh4Ngmb_EhDyQ",
          authDomain: "monitor-bmsce.firebaseapp.com",
          databaseURL:
              "https://monitor-bmsce-default-rtdb.asia-southeast1.firebasedatabase.app",
          projectId: "monitor-bmsce",
          storageBucket: "monitor-bmsce.appspot.com",
          messagingSenderId: "293421021076",
          appId: "1:293421021076:web:05188c9d726ee773bc8181"));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Class Monitoring',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(213, 58, 104, 183)),
          useMaterial3: true,
        ),
        home: FutureBuilder(
            future: moveTo(),
            builder: ((context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(),
                ));
              } else if (snapshot.hasError) {
                // Show an error message if there's an error
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                // Build the widget using the fetched data
                return Center(child: snapshot.data as Widget);
              }
            })));
    // home: const delete());
  }
}

Future<Widget> moveTo() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? login = prefs.getBool('loggedIn');
  String? access = prefs.getString('access');

  if (login != null && login && access != null) {
    if (access == '2') {
      return const Dean();
    } else if (access == '1') {
      return const Convener();
    } else if (access == '3') {
      return const Department();
    } else {
      return const Team();
    }
  } else {
    return const SignInScreen();
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSigningIn = false;
  final _firstFocus = FocusNode();
  final _secondFocus = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: logo(),
            ),
            const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Sign In',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                )),
            Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  focusNode: _firstFocus,
                  onSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_secondFocus);
                  },
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2.0),
                    ),
                  ),
                )),
            Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  focusNode: _secondFocus,
                  onSubmitted: (_) async {
                    setState(() {
                      _isSigningIn = true;
                    });
                    String acc = '';
                    String code = '';
                    final FirebaseAuth auth = FirebaseAuth.instance;
                    try {
                      await auth.signInWithEmailAndPassword(
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                      );
                      DocumentSnapshot<Map<String, dynamic>> access_control =
                          await FirebaseFirestore.instance
                              .collection('Team')
                              .doc(_emailController.text.trim())
                              .get();

                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      acc = access_control['access'].toString();

                      code = access_control['Name'];

                      prefs.setString('access', acc);

                      prefs.setString('name', code);

                      prefs.setString('email', _emailController.text.trim());
                      prefs.setBool('loggedIn', true);

                      switch (acc) {
                        case '2':
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Dean()),
                          );
                          break;
                        case '1':
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Convener()),
                          );
                          break;
                        case '0':
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Team()),
                          );
                        case '3':
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Department()),
                          );
                      }
                    } on FirebaseAuthException {
                      errorFunc(context, 'Credentials mismatch',
                          'Enter valid credentials.');
                    } catch (e) {
                      errorFunc(context, 'Error', 'SignIn was not possible.');
                    } finally {
                      setState(() {
                        _isSigningIn = false;
                      });
                    }
                  },
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2.0),
                    ),
                  ),
                  obscureText: true,
                )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSigningIn
                  ? null
                  : () async {
                      setState(() {
                        _isSigningIn = true;
                      });
                      String acc = '';
                      String code = '';
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      try {
                        await auth.signInWithEmailAndPassword(
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                        );
                        DocumentSnapshot<Map<String, dynamic>> access_control =
                            await FirebaseFirestore.instance
                                .collection('Team')
                                .doc(_emailController.text.trim())
                                .get();

                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();

                        acc = access_control['access'].toString();

                        code = access_control['Name'];

                        prefs.setString('access', acc);

                        prefs.setString('name', code);

                        prefs.setString('email', _emailController.text.trim());
                        prefs.setBool('loggedIn', true);

                        switch (acc) {
                          case '2':
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Dean()),
                            );
                            break;
                          case '1':
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Convener()),
                            );
                            break;
                          case '0':
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Team()),
                            );
                          case '3':
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Department()),
                            );
                        }
                      } on FirebaseAuthException {
                        errorFunc(context, 'Credentials mismatch',
                            'Enter valid credentials.');
                      } catch (e) {
                        errorFunc(context, 'Error', 'SignIn was not possible.');
                      } finally {
                        setState(() {
                          _isSigningIn = false;
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: _isSigningIn
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text(
                      'Sign In',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        )),
      ),
    );
  }
}
