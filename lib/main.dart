import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:r_place_clone/grid_view_widget.dart';
import 'package:r_place_clone/grid_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GridState(),
      child: MaterialApp(
        title: 'r/place Clone',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ScalableGridPainter(),
      ),
    );
  }
}