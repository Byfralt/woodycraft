import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:woody/Module/Drawer.dart';

class Commandes extends StatefulWidget {
  const Commandes({Key? key}) : super(key: key);

  @override
  _CommandesState createState() => _CommandesState();
}

class _CommandesState extends State<Commandes> {
  List<dynamic> commandes = [];

  @override
  void initState() {
    super.initState();
    fetchCommandes();
  }

  // Méthode pour trier les commandes de la plus récente à la plus ancienne
  void sortCommandes() {
    commandes.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return dateB.compareTo(dateA);
    });
  }

  // Méthode pour charger les commandes
  Future<void> fetchCommandes() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:3000/commandes'));
    if (response.statusCode == 200) {
      setState(() {
        commandes = json.decode(response.body);
        sortCommandes(); // Appel de la méthode pour trier les commandes
      });
    } else {
      throw Exception('Erreur lors de la récupération des commandes');
    }
  }

  // Méthode pour charger les commandes en cours
  Future<void> fetchCommandesEnCours() async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:3000/commandes/session_encour'));
    if (response.statusCode == 200) {
      setState(() {
        commandes = json.decode(response.body);
      });
    } else {
      throw Exception('Erreur lors de la récupération des commandes en cours');
    }
  }

  // Méthode pour obtenir la couleur de la pastille en fonction du statut de la commande
  Color getStatusColor(String status) {
    switch (status) {
      case 'En cours':
        return Colors.orange;
      case 'Valider':
        return Colors.green;
      case 'Retard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Méthode pour formater la date
  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  // Méthode pour mettre à jour le statut de la commande
  Future<void> updateCommandeStatus(int orderId, String newStatus) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/commandes/$orderId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'session': newStatus,
      }),
    );
    if (response.statusCode == 200) {
      fetchCommandes();
    } else {
      throw Exception('Échec de la mise à jour du statut de la commande.');
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<dynamic>> groupedCommands = {};
    // Regroupement des commandes en fonction de l'id
    for (var commande in commandes) {
      String orderId = commande['order_id'].toString();
      if (groupedCommands.containsKey(orderId)) {
        groupedCommands[orderId]!.add(commande);
      } else {
        groupedCommands[orderId] = [commande];
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'LES COMMANDES',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              fetchCommandes();
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              fetchCommandesEnCours();
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: ListView.builder(
                itemCount: groupedCommands.length,
                itemBuilder: (BuildContext context, int index) {
                  String orderId = groupedCommands.keys.elementAt(index);
                  List<dynamic> commandesGroup = groupedCommands[orderId]!;

                  dynamic firstCommande = commandesGroup.first;
                  String status = firstCommande['session'];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20.0),
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Commande $orderId',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${firstCommande['forename']} ${firstCommande['surname']}',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                                const SizedBox(width: 5.0),
                                Text(
                                  'Date: ${formatDate(firstCommande['date'])}',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    updateCommandeStatus(
                                      firstCommande['order_id'],
                                      'Valider',
                                    );
                                  },
                                  child: const Text('Valider'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Mettre à jour le statut de la commande à "En cours"
                                    updateCommandeStatus(
                                      firstCommande['order_id'],
                                      'En cours',
                                    );
                                  },
                                  child: const Text('En cours'),
                                ),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: getStatusColor(status),
                                  ),
                                ),
                              ],
                            )         
                          ], 
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
