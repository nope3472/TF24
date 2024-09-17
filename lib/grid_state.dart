import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GridState extends ChangeNotifier {
  static const int GRID_SIZE = 128;
  final Map<int, Color> _grid = {};
  Color? _selectedColor;

  final CollectionReference _gridCollection = FirebaseFirestore.instance.collection('grid');

  Color? get selectedColor => _selectedColor;

  void setSelectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  void updateGrid(int index, Color color) {
    if (index >= 0 && index < GRID_SIZE * GRID_SIZE) {
      if (color == Colors.white) {
        _grid.remove(index);
      } else {
        _grid[index] = color;
      }
      _saveGridState();
      notifyListeners();
    }
  }

  Color getColor(int index) {
    return _grid[index] ?? Colors.white;
  }

  Future<void> _saveGridState() async {
    try {
      final gridMap = _grid.map((key, value) => MapEntry(key.toString(), value.value));
      await _gridCollection.doc('userGrid').set(gridMap);
      print('Grid state saved successfully.');
    } catch (e) {
      print('Error saving grid state: $e');
    }
  }

  Future<void> loadGridState() async {
    try {
      final doc = await _gridCollection.doc('userGrid').get();
      if (doc.exists) {
        final gridMap = Map<int, Color>.from((doc.data() as Map).map(
          (key, value) => MapEntry(int.parse(key), Color(value)),
        ));
        _grid.clear();
        _grid.addAll(gridMap);
        notifyListeners();
        print('Grid state loaded successfully.');
      } else {
        print('No grid state found.');
      }
    } catch (e) {
      print('Error loading grid state: $e');
    }
  }
}
