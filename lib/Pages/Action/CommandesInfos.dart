import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CommandesInfo extends StatefulWidget {
  final int? orderId;

  const CommandesInfo({Key? key, this.orderId}) : super(key: key);

  @override
  State<CommandesInfo> createState() => _CommandesInfoState();
}

class _CommandesInfoState extends State<CommandesInfo> {
  List<dynamic>? commandDetails;
  List<bool> isCheckedList = [];
  Map<int, int> productQuantities = {};

  @override
  void initState() {
    super.initState();
    fetchCommandDetails();
  }

  Future<void> fetchCommandDetails() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/commandes/${widget.orderId}'));
    if (response.statusCode == 200) {
      setState(() {
        commandDetails = json.decode(response.body);
        isCheckedList = List<bool>.filled(commandDetails!.length, false);

        // Regrouper les quantités par ID de produit
        for (final detail in commandDetails!) {
          final productId = detail['product_id'];
          final quantity = detail['quantity'];
          if (productId != null && quantity != null) {
            productQuantities.update(productId, (value) => (value as int) + (quantity as int), ifAbsent: () => quantity as int);
          }
        }
      });
    } else {
      throw Exception('Erreur lors de la récupération des détails de la commande');
    }
  }

  Future<void> validateCommand() async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/commandes/${widget.orderId}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'session': 'Valider',
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Échec de la validation de la commande');
    }
  }

  Widget buildCustomerDetails() {
    if (commandDetails != null && commandDetails!.isNotEmpty) {
      final firstDetail = commandDetails![0];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nom: ${firstDetail['forename']} ${firstDetail['surname']}', style: const TextStyle(fontSize: 16)),
          Text('Adresse: ${firstDetail['add1']}, ${firstDetail['postcode']}', style: const TextStyle(fontSize: 16)),
          Text('Téléphone: ${firstDetail['phone']}', style: const TextStyle(fontSize: 16)),
          Text('Email: ${firstDetail['email']}', style: const TextStyle(fontSize: 16)),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la commande ${widget.orderId}'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Les coordonnées:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: buildCustomerDetails(),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: commandDetails == null
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: productQuantities.length,
                    itemBuilder: (context, index) {
                      final productId = productQuantities.keys.elementAt(index);
                      final quantity = productQuantities[productId];
                      final detail = commandDetails!.firstWhere((detail) => detail['product_id'] == productId);

                      return ListTile(
                        leading: Checkbox(
                          activeColor: const Color(0xFF2DC392),
                          value: isCheckedList[index],
                          onChanged: (value) {
                            setState(() {
                              isCheckedList[index] = value!;
                            });
                          },
                        ),
                        title: Text(detail['product_name'] ?? 'Nom non disponible', style: const TextStyle(fontSize: 18)),
                        subtitle: Text('Quantité totale: ${quantity ?? 'Quantité non disponible'}'),
                        trailing: Text('${detail['product_price'] ?? 'Prix non disponible'} €'),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2DC392),
        onPressed: () {
          validateCommand();
          Navigator.pushNamed(context, '/commandes');
        },
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}
