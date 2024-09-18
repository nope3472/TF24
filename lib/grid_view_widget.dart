import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'grid_state.dart';

class ScalableGridPainter extends StatefulWidget {
  @override
  _ScalableGridPainterState createState() => _ScalableGridPainterState();
}

class _ScalableGridPainterState extends State<ScalableGridPainter> {
  static const int GRID_SIZE = 128;
  final TransformationController _transformationController = TransformationController();
  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final gridState = Provider.of<GridState>(context, listen: false);
    gridState.loadGridState(); // Load the grid state when the widget is initialized
  }

  void _handleTapUp(TapUpDetails details, GridState gridState) {
    final RenderBox renderBox = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(details.globalPosition);

    final Matrix4 matrix = _transformationController.value.clone();
    final Matrix4 invertedMatrix = Matrix4.identity();
    matrix.copyInverse(invertedMatrix);

    final vm.Vector3 position = invertedMatrix.transform3(vm.Vector3(localPosition.dx, localPosition.dy, 0.0));

    final cellSize = renderBox.size.width / GRID_SIZE;
    final x = (position.x / cellSize).floor();
    final y = (position.y / cellSize).floor();

    if (x >= 0 && x < GRID_SIZE && y >= 0 && y < GRID_SIZE) {
      gridState.updateGrid(y * GRID_SIZE + x, gridState.selectedColor!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gridState = Provider.of<GridState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('r/place Clone (64x64)'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // Removed navigation code as per request
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (gridState.remainingCooldownTime > 0)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Cooldown: ${gridState.remainingCooldownTime} seconds',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: InteractiveViewer(
              transformationController: _transformationController,
              boundaryMargin: EdgeInsets.all(double.infinity),
              minScale: 0.1,
              maxScale: 5.0,
              panEnabled: true,
              child: GestureDetector(
                onTapUp: (details) {
                  if (gridState.selectedColor != null && gridState.remainingCooldownTime == 0) {
                    _handleTapUp(details, gridState);
                  } else if (gridState.remainingCooldownTime > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please wait for the cooldown to end')),
                    );
                  }
                },
                child: CustomPaint(
                  key: _canvasKey,
                  painter: GridPainter(gridState: gridState, gridSize: GRID_SIZE),
                  size: Size(GRID_SIZE.toDouble() * 10, GRID_SIZE.toDouble() * 10),
                ),
              ),
            ),
          ),
          ColorPalette(gridState: gridState),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final GridState gridState;
  final int gridSize;

  GridPainter({required this.gridState, required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / gridSize;
    final paint = Paint();

    // Draw the white background
    paint.color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw colored cells
    paint.style = PaintingStyle.fill;
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        final color = gridState.getColor(y * gridSize + x);
        if (color != Colors.white) {
          final rect = Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize);
          paint.color = color;
          canvas.drawRect(rect, paint);
        }
      }
    }

    // Draw grid lines
    paint.color = Colors.grey.withOpacity(0.5);
    paint.strokeWidth = 0.5;
    paint.style = PaintingStyle.stroke;

    // Draw vertical lines
    for (int i = 0; i <= gridSize; i++) {
      final double position = i * cellSize;
      canvas.drawLine(Offset(position, 0), Offset(position, size.height), paint);
    }

    // Draw horizontal lines
    for (int i = 0; i <= gridSize; i++) {
      final double position = i * cellSize;
      canvas.drawLine(Offset(0, position), Offset(size.width, position), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return true;
  }
}

class ColorPalette extends StatelessWidget {
  final GridState gridState;

  ColorPalette({required this.gridState});

  final List<Color> colorPalette = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colorPalette.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              gridState.setSelectedColor(colorPalette[index]);
            },
            child: Container(
              width: 50,
              height: 50,
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: colorPalette[index],
                border: Border.all(
                  color: gridState.selectedColor == colorPalette[index] ? Colors.white : Colors.black,
                  width: 2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
