import 'package:flutter/material.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      _controller.forward();
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Navigator.pushReplacementNamed(context, '/Formulaire');
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: FadeTransition(
        opacity: _controller.drive(CustomTween()),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Ajout d'une ombre derrière le cercle
                        Container(
                          width: 200, // Taille du cercle
                          height: 200, // Taille du cercle
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1), // Réduire l'opacité
                                spreadRadius: 2, // Réduire la propagation de l'ombre
                                blurRadius: 4, // Réduire le flou de l'ombre
                                offset: Offset(0, 2), // changement de position de l'ombre
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover, // Ajuster l'image pour qu'elle remplisse le cercle
                            ),
                          ),
                        ),
                        const SizedBox(height: 40), // Espacement entre le cercle et le texte
                        const Text(
                          'WOODYCRAFT',
                          style: TextStyle(
                            color: const Color(0xFF2DC392),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTween extends Tween<double> {
  CustomTween() : super(begin: 1.0, end: 0.0);

  @override
  double lerp(double t) {
    return math.pow(super.lerp(t), 2) as double;
  }
}
