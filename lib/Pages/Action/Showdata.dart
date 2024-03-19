import 'package:flutter/material.dart';
import 'package:woody/Models/produits.dart';
import 'package:woody/Module/Drawer.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Showdata extends StatefulWidget {
  const Showdata({Key? key}) : super(key: key);
  
  @override
  State<Showdata> createState() => _ShowdataState();
}
  
class _ShowdataState extends State<Showdata> {
  List<Product> products = [];
// Boite de dialogue pour update un produit dans la base de données 
  void showEditDialog(Product product) {
    double newPrice = product.price;
    String newName = product.name;
    String newDescription = product.description;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: product.name,
                decoration: const InputDecoration(labelText: 'Nouveau Nom'),
                onChanged: (value) {
                  newName = value;
                },
              ),
              TextFormField(
                initialValue: product.price.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nouveau prix'),
                onChanged: (value) {
                  newPrice = double.tryParse(value) ?? product.price;
                },
              ),
              TextFormField(
                initialValue: product.description,
                decoration: const InputDecoration(labelText: 'Nouvelle Description'),
                onChanged: (value) {
                  newDescription = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler', style: TextStyle(
                color:  Colors.black,
              ),),
            ),
            ElevatedButton(
              onPressed: () {
                updateOneProduct(product.id, newName, newPrice, newDescription);
                Navigator.of(context).pop();
              },
              child: const Text('Valider', style: TextStyle(
                color: Color(0xFF2DC392),
              ),),
            ),
          ],
        );
      },
    );
  }

  // Boite de dialogue pour effacer un produit avec une double vérification

  void alertDeleteOneProduct(id) {

    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Voulez-vous supprimer ce produit",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                ), 
              ],
            ),
             actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler', style: TextStyle(
                color: Colors.black,
              ),),
            ),
            ElevatedButton(
              onPressed: () {
                deleteOneProduct(id);
                Navigator.of(context).pop();
              },
              child: const Text('Supprimer', style: TextStyle(
                color: Color(0xFF2DC392),
              ),),),
            ],
          ),
        );
      }
    );
  }

  
  
  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    // Server HTTP Get récupération des produits 
    final response =
        await http.get(Uri.parse('http://10.0.2.2:3000/produits'));
    if (response.statusCode == 200) {
      setState(() {
        Iterable list = json.decode(response.body);
        products = list.map((model) => Product.fromJson(model)).toList();
      });
    } else {
      throw Exception('Erreur lors de la récupération des produits');
    }
  }

  Future<void> deleteOneProduct(id) async {
    // Server HTTP Delete, suppression d'un produit selon l'id
    final response =
        await http.delete(Uri.parse('http://10.0.2.2:3000/produits/delete/${id}'));
    if (response.statusCode == 200) {
      fetchProducts();
    } else {
      throw Exception('Erreur lors de la récupération des produits');
    }
  }

Future<void> updateOneProduct(int id, String newName, double newPrice, String newDescription) async {
  // Server HTTP Update, Mise à jour d'un produit dans la base données
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/produits/update/${id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': newName,
        'price': newPrice,
        'describe': newDescription
      }),
    );
    if (response.statusCode == 200) {
      fetchProducts();
    } else {
      throw Exception('Échec de la mise à jour du produit');
    }
  }
  
  

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PRODUITS',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      itemBuilder: (BuildContext context, int index){
                        Product product = products[index];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              // Vérification des images si une l'image existe dans la base données 
                              child: product.image != null
                                  ? Image.asset(
                                      'assets/images/${product.image}',
                                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                        return Container(
                                          color: Color.fromARGB(255, 207, 207, 207), // Couleur rouge pour le carré en cas d'erreur
                                        );
                                      },
                                    )
                                  : Container(
                                      color: Colors.orange, // Couleur orange pour le carré si il n'y a pas d'image
                                    ),
                            ),
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                            const SizedBox(
                              width: double.infinity,
                              height: 5,
                            ),
                            Text(
                              "${product.price.toString()}€",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(
                              width: double.infinity,
                              height: 5,
                            ),
                            Text(
                              product.description,
                              style: const TextStyle(
                                fontSize: 17,
                              
                              ),
                              textAlign: TextAlign.justify,
                            ),
                            const SizedBox(
                              width: double.infinity,
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                      onTap: () {
                                        alertDeleteOneProduct(product.id);
                                      },
                                      child: Container(
                                        width: 50,
                                        height: 50,
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
                                            Icon(Icons.delete, color: const Color(0xFF2DC392),)
                                          ],
                                        )
                                      ),
                                    ),
                                    SizedBox(width: 20,),
                                    GestureDetector(
                                      onTap: () {
                                        showEditDialog(product);
                                      },
                                      child: Container(
                                        width: 50,
                                        height: 50,
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
                                            Icon(Icons.update)
                                          ],
                                        )
                                      ),
                                    ),
                                  ],
                                ),
                            const SizedBox(
                              width: double.infinity,
                              height: 20,
                            ),
                            const Divider(
                              color: Colors.black,
                            ),
                            const SizedBox(
                              width: double.infinity,
                              height: 20,
                            ),

                          ]
                          
                        );
                        
                      }
                    ),
                  ]
                ),
              )
            )
    );
  }
}




