import 'package:flutter/material.dart';
import 'package:madeupu_app/models/token.dart';
import 'package:madeupu_app/screens/cities_screen.dart';
import 'package:madeupu_app/screens/countries_screen.dart';
import 'package:madeupu_app/screens/login_screen.dart';
import 'package:madeupu_app/screens/participation_types_screen.dart';
import 'package:madeupu_app/screens/project_categories_screen.dart';
import 'package:madeupu_app/screens/regions_screen.dart';
import 'package:madeupu_app/screens/user_screen.dart';
import 'package:madeupu_app/screens/users_screen.dart';

import 'document_types_screen.dart';

class HomeScreen extends StatefulWidget {
  final Token token;

  // ignore: use_key_in_widget_constructors
  const HomeScreen({required this.token});

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
    // ignore: unused_local_variable
    List<dynamic> list = [1, 2];
    // ignore: avoid_unnecessary_containers
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
          ListTile(
            leading: const Icon(Icons.flag_rounded),
            title: const Text('Countries'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CountriesScreen(token: widget.token)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.map_rounded),
            title: const Text('Regions'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RegionsScreen(token: widget.token)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.landscape_rounded),
            title: const Text('Cities'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CitiesScreen(token: widget.token)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.group_add_sharp),
            title: const Text('Users'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UsersScreen(token: widget.token)),
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserScreen(
                          token: widget.token,
                          user: widget.token.user,
                          profile: true,
                        )),
              );
            },
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
            leading: const Icon(Icons.business_center_rounded),
            title: const Text('My projects'),
            onTap: () {},
          ),
          const Divider(
            color: Colors.black,
            height: 2,
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserScreen(
                          token: widget.token,
                          user: widget.token.user,
                          profile: true,
                        )),
              );
            },
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
