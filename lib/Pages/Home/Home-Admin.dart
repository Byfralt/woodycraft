import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:woody/Module/Drawer.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({Key? key}) : super(key: key);

  @override
  _HomeAdminState createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int numberOfCommands = 0;
  int numberOfLowStockProducts = 0;
  double totalPriceOfCommands = 0.0;
  double totalPriceOfLastCommand = 0.0;

  @override
  void initState() {
    super.initState();
    fetchCommandesEnCours();
    fetchLowStockProducts();
    fetchTotalPriceOfCommands();
  }
  // NOMBRE DE COMMANDE EN COURS
  Future<void> fetchCommandesEnCours() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/orders'));
    if (response.statusCode == 200) {
      final List<dynamic> commandes = json.decode(response.body);
      setState(() {
        numberOfCommands = commandes.length;
      });
    } else {
      throw Exception('Erreur lors de la récupération des commandes');
    }
  }
  // NOMBRE DE PRODUITS AYANT UN STOCKS BAS (<=5)
  Future<void> fetchLowStockProducts() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/produits'));
    if (response.statusCode == 200) {
      List<dynamic> produits = json.decode(response.body);
      int count = produits.where((produit) => produit['stock'] <= 5).length;
      setState(() {
        numberOfLowStockProducts = count;
      });
    } else {
      throw Exception('Erreur lors de la récupération des produits');
    }
  }
  // RECUPÉRATION DES PRIX DES COMMANDES POUR EN FAIRE UN TOTALE + DERNIERE COMMANDE
  Future<void> fetchTotalPriceOfCommands() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:3000/orders'));
  if (response.statusCode == 200) {
    final List<dynamic> commandes = json.decode(response.body);
    double total = 0.0;
    double lastCommandTotal = 0.0;
    if (commandes.isNotEmpty) {
      // Boucle pour calculer le total de chaque commande
      commandes.forEach((commande) {
        total += (commande['total'] is int) ? commande['total'].toDouble() : commande['total'];
      });

      // Récupération du total de la dernière commande
      final lastCommand = commandes.last;
      lastCommandTotal = (lastCommand['total'] is int) ? lastCommand['total'].toDouble() : lastCommand['total'];
    }

    setState(() {
      totalPriceOfCommands = double.parse(total.toStringAsFixed(2));
      totalPriceOfLastCommand = double.parse(lastCommandTotal.toStringAsFixed(2));
    });
  } else {
    throw Exception('Erreur lors de la récupération des commandes');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'WOODYCRAFT',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'WOODYCRAFT',
                        style: TextStyle(
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/home_admin');
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2DC392),
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "1",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2DC392).withOpacity(1),
                          borderRadius: const BorderRadius.all(Radius.circular(50)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/home_commandes');
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '2',
                              style: TextStyle(
                                color: Color(0xFFD7D7D7),
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2DC392).withOpacity(0.27),
                          borderRadius: const BorderRadius.all(Radius.circular(50)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/home_stocks');
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: Color(0xFFD7D7D7),
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 15,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Admin',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Le Lorem Ipsum est simplement du faux texte employé dans la composition et la mise en page avant impression. Le Lorem Ipsum est le faux texte standard de l\'imprimerie depuis les années 1500, quand un imprimeur anonyme assembla ensemble des morceaux de texte pour réaliser un livre spécimen de polices de texte.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/commandes');
                                  },
                                  child: Container(
                                    width: 125,
                                    height: 125,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            spreadRadius: 1,
                                            blurRadius: 4,
                                          )
                                        ]
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$numberOfCommands',
                                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2DC392)),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          "Commandes",
                                          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/stocks');
                                  },
                                  child: Container(
                                    width: 125,
                                    height: 125,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            spreadRadius: 1,
                                            blurRadius: 4,
                                          )
                                        ]
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$numberOfLowStockProducts', 
                                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2DC392)),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          "Stocks faibles",
                                          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              ],
                            ),
                            const SizedBox(height: 35,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/home_admin');
                                  },
                                  child: Container(
                                      width:125,
                                      height:125,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              spreadRadius: 1,
                                              blurRadius: 4,
                                            )
                                          ]
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '$totalPriceOfCommands €', 
                                            style: const TextStyle(fontSize: 24, color:Color(0xFF2DC392), fontWeight: FontWeight.bold ),
                                            textAlign: TextAlign.center,
                                            
                                          ),
                                          const Text(
                                            'Recette total', 
                                            
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      )
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    fetchTotalPriceOfCommands();
                                  },
                                  child: Container(
                                    width: 125,
                                    height: 125,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 4,
                                        )
                                      ]
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${totalPriceOfLastCommand.toStringAsFixed(2)} €', 
                                          style: const TextStyle(fontSize: 24, color: Color(0xFF2DC392), fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        const Text(
                                          'Last commande', 
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    )
                                  ),
                                ),


                              ],
                            ),
                            const SizedBox(height: 35,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/home_admin');
                                  },
                                  child: Container(
                                    width:125,
                                    height:125,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 4,
                                        )
                                      ]
                                    ),
                                    child: const Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.delete,color:Color(0xFF2DC392),),
                                        SizedBox(height: 10,),
                                        Text("Supprimer\n un produit",style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)), textAlign: TextAlign.center,),
                                      ],
                                    )
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/home_admin');
                                  },
                                  child: Container(
                                    width:125,
                                    height:125,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 4,
                                        )
                                      ]
                                    ),
                                    child: const Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_shopping_cart,color:Color(0xFF2DC392),),
                                        SizedBox(height: 10,),
                                        Text("Ajouter un \n produit",style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)), textAlign: TextAlign.center,),
                                      ],
                                    )
                                  ),
                                ),
                                
                              ],
                            ),
                            const SizedBox(height: 35,),                               
                          ],
                        ),
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
