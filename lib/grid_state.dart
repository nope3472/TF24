import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:r_place_clone/colldownmanager.dart';

class GridState extends ChangeNotifier {
  static const int GRID_SIZE = 256 * 424; // Grid size constant
  final Map<int, Color> _grid = {}; // Stores the color of each grid cell
  Color? _selectedColor; // Selected color by the user
  int _remainingCooldownTime = 0; // Time left for cooldown

  final CollectionReference _gridCollection =
      FirebaseFirestore.instance.collection('grid');
  final CooldownManager _cooldownManager = CooldownManager();

  Color? get selectedColor => _selectedColor;
  int get remainingCooldownTime => _remainingCooldownTime;

  GridState() {
    _init(); // Initialize the grid state and cooldown
  }

  // Initializes the grid state and resumes cooldown if needed
  void _init() {
    _listenToGridChanges(); // Listen to Firestore changes
    _resumeCooldownIfNeeded(); // Resume cooldown if it's active
  }

  // Sets the selected color
  void setSelectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  // Retrieves the color of a grid cell, defaults to white
  Color getColor(int index) {
    return _grid[index] ?? Colors.white;
  }

  // Updates a grid cell's color with cooldown check
  Future<void> updateGrid(int index, Color color) async {
    if (!_isValidIndex(index)) return;

    try {
      if (await _cooldownManager.canColorPixel()) {
        _applyColorToGrid(index, color);
        await _saveGridState(); // Save grid to Firestore
        await _cooldownManager.recordPixelColored(); // Record event
        _startCooldownTimer(); // Start cooldown
      } else {
        throw Exception('Cooldown period is active');
      }
    } catch (e) {
    }
  }

  // Checks if the index is valid for the grid
  bool _isValidIndex(int index) {
    return index >= 0 && index < GRID_SIZE;
  }

  // Applies the selected color to the grid and notifies listeners
  void _applyColorToGrid(int index, Color color) {
    if (color == Colors.white) {
      _grid.remove(index); // Remove color (reset to white)
    } else {
      _grid[index] = color;
    }
    notifyListeners();
  }

  // Starts the cooldown timer and updates the state every second
  void _startCooldownTimer() async {
    while (await _cooldownManager.getRemainingCooldownTime() > 0) {
      _remainingCooldownTime =
          await _cooldownManager.getRemainingCooldownTime();
      notifyListeners();
      await Future.delayed(const Duration(seconds: 1));
    }
    _remainingCooldownTime = 0;
    notifyListeners();
  }

  // Resumes cooldown if necessary
  Future<void> _resumeCooldownIfNeeded() async {
    int remainingTime = await _cooldownManager.getRemainingCooldownTime();
    if (remainingTime > 0) {
      _remainingCooldownTime = remainingTime;
      _startCooldownTimer();
    }
  }

  // Saves the current grid state to Firestore
  Future<void> _saveGridState() async {
    try {
      final gridMap =
          _grid.map((key, value) => MapEntry(key.toString(), value.value));
      await _gridCollection.doc('userGrid').set(gridMap);
    } catch (e) {
    }
  }

  // Listens for real-time changes in Firestore and updates the grid
  void _listenToGridChanges() {
    _gridCollection.doc('userGrid').snapshots().listen(
      (snapshot) {
        if (snapshot.exists) {
          _updateGridFromFirestore(snapshot);
        }
      },
      onError: (error) {
      },
    );
  }

  // Updates the local grid based on Firestore changes
  void _updateGridFromFirestore(DocumentSnapshot snapshot) {
    final gridMap = Map<int, Color>.from(
      (snapshot.data() as Map)
          .map((key, value) => MapEntry(int.parse(key), Color(value))),
    );
    _grid
      ..clear()
      ..addAll(gridMap);
    notifyListeners();
  }
}