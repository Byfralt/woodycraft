
// main.dart
import 'package:flutter/material.dart';
import 'package:woody/Pages/Action/Commandes.dart';
import 'package:woody/Pages/Action/Stocks.dart';
import 'package:woody/Pages/Home/Home-Admin.dart';


import './Pages/Home/Home-Stocks.dart';
import './Pages/Home/Home-Commandes.dart';

import './Pages/Start/HomeFormulaire.dart';
import './Pages/Start/HomeScreen2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/home_admin',
      routes: {
        // Route avant connexion
        '/': (context) => const HomeScreen(),
        '/Formulaire': (context) => const FormScreen(),

        // Route apres connexion
        '/home_admin': (context) => const HomeAdmin(),
        '/home_commandes': (context) => const HomeWoodycraft(),
        '/home_stocks': (context) => const HomeWoodycraftStocks(),

        // Route Actions
        '/commandes': (context) => const Commandes(),
        '/stocks': (context) => const Stocks(),
      },
    );
  }
}

// ceci est un teste github
