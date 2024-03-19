// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class FormScreen extends StatelessWidget {
  const FormScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF2DC392),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
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
                  child: Center(
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Nom d\'utilisateur',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Mot de passe',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                String username = usernameController.text;
                                String password = passwordController.text;

                                var response = await http.post(
                                  Uri.parse('http://10.0.2.2:3000/login'),
                                  body: {
                                    'name': username,
                                    'password': password,
                                  },
                                );

                                if (response.statusCode == 200) {
                                  print('Connexion réussie');
                                  Navigator.pushReplacementNamed(
                                      context, '/home_admin');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Nom d\'utilisateur ou mot de passe incorrect',
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Se connecter',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        )
                      ],
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
