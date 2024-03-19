import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // ListView est la liste d'éléments
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            color: const Color(0xFF2DC392),
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/logo.png'),
                    radius: 40,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Admin Woodycraft',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '01 02 03 04 05',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Woodycraft@gmail.com',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: const Text('Accueil'),
            onTap: () {
              Navigator.pushNamed(context, '/home_admin');
            },
          ),
          ListTile(
            title: const Text('Les Commandes'),
            onTap: () {
              Navigator.pushNamed(context, '/commandes');
            },
          ),
          ListTile(
            title: const Text('Nos Stocks'),
            onTap: () {
              Navigator.pushNamed(context, '/stocks');
            },
          ),
          ListTile(
            title: const Text('Nos Produits'),
            onTap: () {
              Navigator.pushNamed(context, '/showdata');
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
