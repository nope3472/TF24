import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:r_place_clone/grid_view_widget.dart';
import 'package:r_place_clone/grid_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Initialize Firebase asynchronously
  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      print("Firebase initialized successfully");
    } catch (e) {
      print("Error initializing Firebase: $e");
      throw e; // Re-throw the error to handle it in FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GridState(),
      child: MaterialApp(
        title: 'r/place Clone',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FutureBuilder(
          future: _initializeFirebase(),
          builder: (context, snapshot) {
            // Check for initialization errors
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('Error initializing Firebase: ${snapshot.error}'),
                ),
              );
            }

            // Show a loading indicator while Firebase initializes
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Once Firebase is initialized, show the home screen
            return ScalableGridPainter();
          },
        ),
      ),
    );
  }
}
