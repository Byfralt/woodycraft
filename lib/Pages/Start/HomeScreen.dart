// home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtenez la hauteur de l'écran
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF2DC392),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Fond coloré en arrière-plan
          Container(
            color: const Color(0xFF2DC392),
            height: double.infinity,
            width: double.infinity,
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.65,
            child: Image.asset(
              'assets/images/bulle.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  // color: Colors.red,
                  child: Center(
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  // color: Colors.red,
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/Formulaire');
                      },
                      child: Container(
                        width: 300,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            'WOODYCRAFT',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
