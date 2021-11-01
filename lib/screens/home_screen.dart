import 'package:flutter/material.dart';
import 'package:madeupu_app/models/token.dart';
import 'package:madeupu_app/screens/login_screen.dart';
import 'package:madeupu_app/screens/participation_types_screen.dart';
import 'package:madeupu_app/screens/project_categories_screen.dart';

import 'document_types_screen.dart';

class HomeScreen extends StatefulWidget {
  final Token token;

  HomeScreen({required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
      ),
      body: _getBody(),
      drawer: widget.token.user.userType == 0
          ? _getAdminMenu()
          : _getCustomerMenu(),
    );
  }

  Widget _getBody() {
    List<dynamic> list = [1, 2];
    return Container(
        //onRefresh: ,
        child: const Text('Project 1'));
  }

  Widget _getAdminMenu() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            child: Image(
              image: AssetImage('assets/logo.png'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.portrait_rounded),
            title: const Text('Document types'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        DocumentTypesScreen(token: widget.token)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.device_hub_rounded),
            title: const Text('Participation types'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ParticipationTypesScreen(token: widget.token)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded),
            title: const Text('Project category'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProjectCategoriesScreen(token: widget.token)),
              );
            },
          ),
          const Divider(
            color: Colors.black,
            height: 2,
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit profile'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Log out'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _getCustomerMenu() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            child: Image(
              image: AssetImage('assets/logo.png'),
            ),
          ),
          ListTile(
            leading: Icon(Icons.business_center_rounded),
            title: Text('My projects'),
            onTap: () {},
          ),
          const Divider(
            color: Colors.black,
            height: 2,
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit profile'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Log out'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
