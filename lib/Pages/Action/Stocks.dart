import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:woody/Models/produits.dart';
import 'package:woody/Module/Drawer.dart';

class Stocks extends StatefulWidget {
  const Stocks({Key? key}) : super(key: key);

  @override
  _StocksState createState() => _StocksState();
}

class _StocksState extends State<Stocks> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  // Méthode pour charger les produits
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

  // Méthode pour mettre à jour le stock d'un produit
  Future<void> updateProduct(Product product, int newStock) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/produits/${product.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'stock': newStock,
      }),
    );
    if (response.statusCode == 200) {
      fetchProducts();
    } else {
      throw Exception('Échec de la mise à jour du produit');
    }
  }

  void showEditDialog(Product product) {
    int newStock = product.stock;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: product.stock.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Nouveau stock'),
                onChanged: (value) {
                  newStock = int.tryParse(value) ?? product.stock;
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
                updateProduct(product, newStock);
                Navigator.of(context).pop();
              },
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'NOS STOCKS',
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                Product product = products[index];
                bool stockBas = product.stock < 5 && product.stock > 0;
                bool stockNul = product.stock == 0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Stock: ${product.stock}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (stockBas)
                      const Text(
                        '📢​ ​Attention au stock',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (stockNul)
                      const Text(
                        '📢​ Plus de stock',
                        style: TextStyle(
                          color: Color.fromARGB(255, 172, 33, 33),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ElevatedButton(
                      onPressed: () {
                        showEditDialog(product);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2DC392),
                      ),
                      child: Text(
                        'Modifier',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 20.0),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
