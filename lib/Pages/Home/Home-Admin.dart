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

 void showAddDialog() {
  double newPrice = 1;
  String newName = "";
  String newDescription = "";
  String newImage = "";
  int newStock = 1;
  int newCat = 1;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      final Size size = MediaQuery.of(context).size;
      return Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.zero,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: size.width,
                  height: size.height,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Ajouter un Produit',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: Color(0xFF2DC392),
                            ),
                          ),
                        ),
                        TextFormField(
                          initialValue: "",
                          decoration: const InputDecoration(labelText: 'Image'),
                          onChanged: (value) {
                            newImage = value;
                          },
                        ),
                        TextFormField(
                          initialValue: "",
                          decoration: const InputDecoration(labelText: 'Nom'),
                          onChanged: (value) {
                            newName = value;
                          },
                        ),
                        TextFormField(
                          initialValue: "",
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Prix'),
                          onChanged: (value) {
                            newPrice = double.tryParse(value) ?? 1;
                          },
                        ),
                        TextFormField(
                          initialValue: "",
                          decoration: const InputDecoration(labelText: 'Description'),
                          onChanged: (value) {
                            newDescription = value;
                          },
                        ),
                        TextFormField(
                          initialValue: "",
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Stock'),
                          onChanged: (value) {
                            newStock = int.parse(value);
                          },
                        ),
                        DropdownButtonFormField<int>(
                          value: newCat,
                          decoration: const InputDecoration(labelText: 'Catégorie'),
                          onChanged: (value) {
                            setState(() {
                              newCat = value ?? 1;
                            });
                          },
                          items: const [
                            DropdownMenuItem<int>(
                              value: 1,
                              child: Text('Véhicule'),
                            ),
                            DropdownMenuItem<int>(
                              value: 2,
                              child: Text('Instrument'),
                            ),
                             DropdownMenuItem<int>(
                              value: 3,
                              child: Text('Steampunk'),
                            ),
                            DropdownMenuItem<int>(
                              value: 4,
                              child: Text('Autre'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Annuler', style: TextStyle(
                                color: Colors.black,
                                 fontSize: 20,
                              ),)
                            ),
                            ElevatedButton(
                              onPressed: () {
                                addOneProduct(newName, newPrice, newDescription, newStock, newImage, newCat);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Valider', style: TextStyle(
                                color: const Color(0xFF2DC392),
                                fontSize: 20,
                              ),),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


  @override
  void initState() {
    super.initState();
    fetchCommandesEnCours();
    fetchLowStockProducts();
    fetchTotalPriceOfCommands();
  }

  // Ajout d'un produit dans la base de données 

  Future<void> addOneProduct(String newName, double newPrice, String newDescription, int newStock, String newImage, int newCat) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/produits/add'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': newName,
        'price': newPrice,
        'describe': newDescription,
        'stock': newStock,
        'image': newImage,
        'cat': newCat
      }),
    );
    if (response.statusCode == 200) {
      print("ok");
    } else {
      throw Exception('Échec de la mise à jour du produit');
    }
  }

  // Nombre de commandes en cours
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
  // Nombre de commandes ayant un stock bas (>5)
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
  // Recupération des prix des commandes pour en faire un total + dernière commande 
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
                          "L'application Admin Woodycraft réinvente l'achat de puzzles en bois 3D. Avec une gestion simplifiée et une interface intuitive, elle redéfinit l'expérience client en ligne. Découvrez une nouvelle façon d'explorer et d'acheter des puzzles artistiques. Bienvenue chez Woodycraft, où la passion rencontre l'innovation.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 13,
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
                                    // ;
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
                                            'Recettes des \n commandes', 
                                            
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
                                          'Dernière \n commande', 
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
                                    Navigator.pushNamed(context, '/showdata');
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
                                        Icon(Icons.update,color:Color(0xFF2DC392),),
                                        SizedBox(height: 10,),
                                        Text("Afficher \n les produits",style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)), textAlign: TextAlign.center,),
                                      ],
                                    )
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showAddDialog();
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
