import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:madeupu_app/components/loader_component.dart';
import 'package:madeupu_app/helpers/api_helper.dart';
import 'package:madeupu_app/models/response.dart';
import 'package:madeupu_app/models/token.dart';
import 'package:madeupu_app/models/user.dart';
import 'package:madeupu_app/screens/user_screen.dart';

class UserInfoScreen extends StatefulWidget {
  final Token token;
  final User user;

  // ignore: use_key_in_widget_constructors
  const UserInfoScreen({required this.token, required this.user});

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  bool _showLoader = false;
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_user.fullName),
      ),
      body: Center(
        child: _showLoader
            ? const LoaderComponent(
                text: 'Por favor espere...',
              )
            : _getContent(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _goAdd(),
      ),
    );
  }

  Widget _showUserInfo() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: FadeInImage(
                    placeholder: const AssetImage('assets/logo.png'),
                    image: NetworkImage(_user.imageFullPath),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover),
              ),
              Positioned(
                  bottom: 0,
                  left: 60,
                  child: InkWell(
                    onTap: () => _goEdit(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        color: Colors.green[50],
                        height: 40,
                        width: 40,
                        child: const Icon(
                          Icons.edit,
                          size: 30,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ))
            ],
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Text('Email: ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              _user.email,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: <Widget>[
                            const Text('Tipo documento: ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              _user.documentType.description,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: <Widget>[
                            const Text('Documento: ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              _user.document,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: <Widget>[
                            const Text('Dirección: ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              _user.address,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: <Widget>[
                            const Text('Teléfono: ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              _user.phoneNumber,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goEdit() async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserScreen(
                  token: widget.token,
                  user: _user,
                  profile: false,
                )));
    if (result == 'yes') {
      //TODO: Pending refresh user info
    }
  }

  Future<void> _getUser() async {
    setState(() {
      _showLoader = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: 'Verifica que estes conectado a internet.',
          actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }

    Response response = await ApiHelper.getUser(widget.token, _user.id);

    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: response.message,
          actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }

    setState(() {
      _user = response.result;
    });
  }

  _goAdd() {}

  Widget _getContent() {
    return Column(
      children: <Widget>[
        _showUserInfo(),
        const Expanded(
          //child: _user.vehicles.length == 0 ? _noContent() : _getListView(),
          child: Text('Prueba'),
        ),
      ],
    );
  }
/*
  Widget _getListView() {
    return RefreshIndicator(
      onRefresh: _getUser,
      child: ListView(
        children: _user.vehicles.map((e) {
          return Card(
            child: InkWell(
              onTap: () => _goVehicle(),
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    FadeInImage(
                      placeholder: AssetImage('assets/vehicle_logo.png'),
                      image: NetworkImage(e.imageFullPath),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                e.plaque,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Text(
                                    e.vehicleType.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    e.brand.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    e.line,
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    e.color,
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 40,
                    )
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: const Text(
          'El usuario no tiene vehículos registrados.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }*/

  //void _goVehicle() {}
}
