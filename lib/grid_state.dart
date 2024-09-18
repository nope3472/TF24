import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:r_place_clone/colldownmanager.dart';


class GridState extends ChangeNotifier {
  static const int GRID_SIZE = 128;
  final Map<int, Color> _grid = {};
  Color? _selectedColor;

  final CollectionReference _gridCollection = FirebaseFirestore.instance.collection('grid');

  Color? get selectedColor => _selectedColor;
  final CooldownManager _cooldownManager = CooldownManager();
  int _remainingCooldownTime = 0;

  int get remainingCooldownTime => _remainingCooldownTime;

  Future<void> updateGrid(int index, Color color) async {
    if (await _cooldownManager.canColorPixel()) {
      if (index >= 0 && index < GRID_SIZE * GRID_SIZE) {
        if (color == Colors.white) {
          _grid.remove(index);
        } else {
          _grid[index] = color;
        }
        await _saveGridState();
        await _cooldownManager.recordPixelColored();
        _startCooldownTimer();
        notifyListeners();
      }
    } else {
      throw Exception('Cooldown period is active');
    }
  }

  void _startCooldownTimer() async {
    while (await _cooldownManager.getRemainingCooldownTime() > 0) {
      _remainingCooldownTime = await _cooldownManager.getRemainingCooldownTime();
      notifyListeners();
      await Future.delayed(Duration(seconds: 1));
    }
    _remainingCooldownTime = 0;
    notifyListeners();
  }

  Future<void> _resumeCooldownIfNeeded() async {
    int remainingTime = await _cooldownManager.getRemainingCooldownTime();
    if (remainingTime > 0) {
      _remainingCooldownTime = remainingTime;
      _startCooldownTimer(); // Start the cooldown timer if there is remaining time
    }
  }

  void setSelectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
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
        await _resumeCooldownIfNeeded(); // Check and resume cooldown if needed
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
