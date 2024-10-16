import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:r_place_clone/events.dart';
import 'package:r_place_clone/grid_view_widget.dart';
import 'package:r_place_clone/sign_in_page.dart';
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildForeground(context),
        ],
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(
          bottom:
          MediaQuery.of(context).size.height * 0.02, // Responsive margin
          left: MediaQuery.of(context).size.width * 0.08, // Responsive margin
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScalableGridPainter()),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height *
                  0.03, // Responsive padding
              horizontal: MediaQuery.of(context).size.width *
                  0.08, // Responsive padding
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 136, 119, 223),
                  Color.fromARGB(229, 50, 15, 223)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'EXPLORE PIXELFIESTA',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width *
                        0.045, // Responsive font size
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildBackground() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background_image.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
  Widget _buildForeground(BuildContext context) {
    return Column(
      children: [
        _buildAppBar(context),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        const Expanded(
          child: EventsPage(),
        ), // Embed the EventsPage directly
      ],
    );
  }
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical:
        MediaQuery.of(context).size.height * 0.01, // Responsive padding
        horizontal:
        MediaQuery.of(context).size.width * 0.03, // Responsive padding
      ),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Text('Tantra',
                style: GoogleFonts.poppins(
                    color: const Color(0xFF0EEFFB),
                    fontSize: MediaQuery.of(context).size.width *
                        0.06, // Responsive font size
                    fontWeight: FontWeight.w500)),
            Text('Fiesta',
                style: GoogleFonts.poppins(
                    color: const Color(0xFF36EDC4),
                    fontSize: MediaQuery.of(context).size.width *
                        0.06, // Responsive font size
                    fontWeight: FontWeight.w500)),
            Text(' 2k',
                style: GoogleFonts.poppins(
                    color: const Color(0xFF36EDC4),
                    fontSize: MediaQuery.of(context).size.width *
                        0.06, // Responsive font size
                    fontWeight: FontWeight.w500)),
            Text('24',
                style: GoogleFonts.poppins(
                    color: const Color(0xFF0EEFFB),
                    fontSize: MediaQuery.of(context).size.width *
                        0.06, // Responsive font size
                    fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Color(0xFF0EEFFB)),
            iconSize: MediaQuery.of(context).size.width *
                0.07, // Responsive icon size
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const SignIn()));
            },
          ),
        ],
      ),
    );
  }
}