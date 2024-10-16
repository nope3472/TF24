//try 3
import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:r_place_clone/sign_in_page.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'grid_state.dart';

class ScalableGridPainter extends StatefulWidget {
  const ScalableGridPainter({super.key});

  @override
  _ScalableGridPainterState createState() => _ScalableGridPainterState();
}

class _ScalableGridPainterState extends State<ScalableGridPainter> {
  static const int gridWidth = 256;
  static const int gridHeight = 422;
  final TransformationController _transformationController =
      TransformationController();
  final GlobalKey _canvasKey = GlobalKey();
  Timer? _cooldownTimer;
  bool isCooldownActive = false; // Add this variable
  int cooldownDuration = 15; // Duration of cooldown in seconds

  @override
  void initState() {
    super.initState();
    final gridState = Provider.of<GridState>(context, listen: false);
    // Start cooldown timer if needed
    if (gridState.remainingCooldownTime > 0) {
      startCooldownTimer(gridState.remainingCooldownTime);
    }
  }

  void _handleTapUp(TapUpDetails details, GridState gridState) {
    if (isCooldownActive) return; // Prevent taps if cooldown is active

    final RenderBox renderBox =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localPosition =
        renderBox.globalToLocal(details.globalPosition);

    final Matrix4 matrix = _transformationController.value.clone();
    final Matrix4 invertedMatrix = Matrix4.identity();
    matrix.copyInverse(invertedMatrix);

    final vm.Vector3 position = invertedMatrix
        .transform3(vm.Vector3(localPosition.dx, localPosition.dy, 0.0));

    final cellSize = renderBox.size.width / gridWidth;
    final x = (position.x / cellSize).floor();
    final y = (position.y / cellSize).floor();

    if (x >= 0 && x < gridWidth && y >= 0 && y < gridHeight) {
      gridState.updateGrid(y * gridWidth + x, gridState.selectedColor!);
      isCooldownActive = true; // Activate cooldown after a tap
      startCooldownTimer(cooldownDuration); // Start cooldown timer
    }
  }

  void startCooldownTimer(int cooldownTime) {
    _cooldownTimer?.cancel(); // Cancel any existing timer
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (cooldownTime > 0) {
        setState(() {
          cooldownTime--;
        });
      } else {
        setState(() {
          isCooldownActive = false; // Reset cooldown when timer ends
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel(); // Cancel the timer when widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gridState = Provider.of<GridState>(context);

    // Get screen width and height for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0), // Set your desired height
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 136, 119, 223),
                Color.fromARGB(229, 50, 15, 223),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PixelFiesta',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isCooldownActive) // Show cooldown timer
                  Text(
                    'Cooling Down',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
            backgroundColor:
                Colors.transparent, // Make the background transparent
            actions: [
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignIn()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              transformationController: _transformationController,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              minScale: 0.1,
              maxScale: 20.0,
              panEnabled: true,
              child: GestureDetector(
                onTapUp: (details) {
                  if (gridState.selectedColor != null && !isCooldownActive) {
                    // Prevent tap if cooldown is active
                    _handleTapUp(details, gridState);
                  }
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cellSize = constraints.maxWidth / gridWidth;
                    final canvasHeight = cellSize * gridHeight;

                    return CustomPaint(
                      key: _canvasKey,
                      painter: GridPainter(
                        gridState: gridState,
                        gridWidth: gridWidth,
                        gridHeight: gridHeight,
                      ),
                      size: Size(gridWidth.toDouble() * cellSize, canvasHeight),
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 136, 119, 223),
                  Color.fromARGB(229, 50, 15, 223),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: ColorPalette(gridState: gridState, screenWidth: screenWidth),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final GridState gridState;
  final int gridWidth;
  final int gridHeight;

  GridPainter(
      {required this.gridState,
      required this.gridWidth,
      required this.gridHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / gridWidth;
    final paint = Paint();

    paint.color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    paint.style = PaintingStyle.fill;
    for (int y = 0; y < gridHeight; y++) {
      for (int x = 0; x < gridWidth; x++) {
        final color = gridState.getColor(y * gridWidth + x);
        if (color != Colors.white) {
          final rect =
              Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize);
          paint.color = color;
          canvas.drawRect(rect, paint);
        }
      }
    }

    paint.color = Colors.grey.withOpacity(0.4);
    paint.strokeWidth = 0.2;
    paint.style = PaintingStyle.stroke;

    for (int i = 0; i <= gridWidth; i++) {
      final double position = i * cellSize;
      canvas.drawLine(
          Offset(position, 0), Offset(position, size.height), paint);
    }

    for (int i = 0; i <= gridHeight; i++) {
      final double position = i * cellSize;
      canvas.drawLine(Offset(0, position), Offset(size.width, position), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return true;
  }
}

// ColorPalette class
class ColorPalette extends StatefulWidget {
  final GridState gridState;
  final double screenWidth;

  const ColorPalette({super.key, required this.gridState, required this.screenWidth});

  @override
  _ColorPaletteState createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<ColorPalette> {
  bool _canSelectColor = true; // Cooldown flag

  final List<Color> colorPalette = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.black,
    Colors.white,
    Colors.pink,
    Colors.cyan,
    Colors.teal,
    Colors.lime,
    Colors.indigo,
    Colors.brown,
    Colors.grey,
    Colors.amber,
    Colors.deepOrange,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.deepPurple,
    Colors.blueGrey,
    Colors.orangeAccent,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.yellowAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
    Colors.cyanAccent,
    Colors.tealAccent,
    Colors.limeAccent,
    Colors.indigoAccent,
    Colors.brown,
  ];

  void _onColorTap(Color color) {
    if (_canSelectColor) {
      widget.gridState.setSelectedColor(color); // Set the selected color
      _canSelectColor = false; // Disable further selections
      // Start cooldown
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _canSelectColor = true; // Re-enable after cooldown
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemSize =
        widget.screenWidth / 9; // Adjusts color blocks based on screen width

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: colorPalette.asMap().entries.map((entry) {
            Color color = entry.value;
            return GestureDetector(
              onTap: () => _onColorTap(color), // Handle color tap
              child: Container(
                width: itemSize,
                height: itemSize,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                    color: widget.gridState.selectedColor == color
                        ? Colors.black
                        : Colors.white,
                    width: 2,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}