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
                decoration: InputDecoration(labelText: 'Nouveau Nom'),
                onChanged: (value) {
                  newName = value;
                },
              ),
              TextFormField(
                initialValue: product.price.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Nouveau prix'),
                onChanged: (value) {
                  newPrice = double.tryParse(value) ?? product.price;
                },
              ),
              TextFormField(
                initialValue: product.description,
                decoration: InputDecoration(labelText: 'Nouvelle Description'),
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
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                updateOneProduct(product.id, newName, newPrice, newDescription);
                Navigator.of(context).pop();
              },
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  void alertDeleteOneProduct(id) {

    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Voulez-vous supprimer ce produit",
                style: const TextStyle(
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
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteOneProduct(id);
                Navigator.of(context).pop();
              },
              child: Text('Enregistrer'),
              ),
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
    final response =
        await http.delete(Uri.parse('http://10.0.2.2:3000/produits/delete/${id}'));
    if (response.statusCode == 200) {
      fetchProducts();
    } else {
      throw Exception('Erreur lors de la récupération des produits');
    }
  }

Future<void> updateOneProduct(int id, String newName, double newPrice, String newDescription) async {
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
                            // Image.asset('assets/images/${product.image}'),
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 15,
                            ),
                            Text(
                              "${product.price.toString()}€",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 15,
                            ),
                            Text(
                              product.description,
                              style: const TextStyle(
                                fontSize: 17,
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.delete)
                                          ],
                                        )
                                      ),
                                    ),
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
                                        child: Column(
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
                            SizedBox(
                              width: double.infinity,
                              height: 25,
                            ),
                            Divider(
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 25,
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




