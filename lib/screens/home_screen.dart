import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:madeupu_app/helpers/api_helper.dart';
import 'package:madeupu_app/models/response.dart';
import 'package:madeupu_app/models/token.dart';
import 'package:madeupu_app/screens/cities_screen.dart';
import 'package:madeupu_app/screens/countries_screen.dart';
import 'package:madeupu_app/screens/login_screen.dart';
import 'package:madeupu_app/screens/participation_types_screen.dart';
import 'package:madeupu_app/screens/project_categories_screen.dart';
import 'package:madeupu_app/screens/projects_by_user.dart';
import 'package:madeupu_app/screens/projects_screen.dart';
import 'package:madeupu_app/screens/regions_screen.dart';
import 'package:madeupu_app/screens/user_screen.dart';
import 'package:madeupu_app/screens/users_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'document_types_screen.dart';

class HomeScreen extends StatefulWidget {
  final Token token;

  const HomeScreen({Key? key, required this.token}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
      ),
      body: ProjectsScreen(token: widget.token),
      drawer: widget.token.user.userType == 0
          ? _getAdminMenu()
          : _getCustomerMenu(),
    );
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
            leading: const Icon(Icons.business_center_rounded),
            title: const Text('My projects'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProjectsByUser(token: widget.token)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Log out'),
            onTap: () {
              _removeUser();
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProjectsByUser(token: widget.token)),
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
              _removeUser();
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

  Future<void> _getUser() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: 'Verify that you are connected to the internet.',
          actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Accept'),
          ]);
      return;
    }

    Response response =
        await ApiHelper.getUser(widget.token, widget.token.user.id);

    if (!response.isSuccess) {
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: response.message,
          actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Accept'),
          ]);
      return;
    }
    widget.token.user = response.result;
  }

  void _removeUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
