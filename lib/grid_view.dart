import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'grid_state.dart';

class GridViewWidget extends StatelessWidget {
  final int gridWidth;
  final int gridHeight;

  GridViewWidget({required this.gridWidth, required this.gridHeight});

  @override
  Widget build(BuildContext context) {
    final gridState = Provider.of<GridState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('r/place IIITN'),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: gridWidth / gridHeight, // Adjust grid aspect ratio
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridWidth,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            itemCount: gridWidth * gridHeight,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  gridState.updateGrid(index, Colors.blue);
                },
                child: Container(
                  color: gridState.getColor(index),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}