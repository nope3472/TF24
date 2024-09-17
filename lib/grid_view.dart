import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'grid_state.dart';

class GridViewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gridState = Provider.of<GridState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('r/place Clone'),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1.0, // Square grid
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 32, // 32x32 grid
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            itemCount: 1024, // 32x32
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  gridState.updateGrid(index, Colors.blue); // Set the color to blue on tap
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