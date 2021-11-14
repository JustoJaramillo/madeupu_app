import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:madeupu_app/components/loader_component.dart';
import 'package:madeupu_app/helpers/api_helper.dart';
import 'package:madeupu_app/helpers/app_colors.dart';
import 'package:madeupu_app/models/participations.dart';
import 'package:madeupu_app/models/project.dart';
import 'package:madeupu_app/models/response.dart';
import 'package:madeupu_app/models/token.dart';

class ParticipationScreen extends StatefulWidget {
  final Token token;
  final Project project;
  const ParticipationScreen(
      {Key? key, required this.token, required this.project})
      : super(key: key);

  @override
  _ParticipationScreenState createState() => _ParticipationScreenState();
}

class _ParticipationScreenState extends State<ParticipationScreen> {
  bool _showLoader = false;
  //bool _somethingNew = false;
  List<Participations> _participations = [];

  @override
  void initState() {
    super.initState();
    _noCreatorUser(widget.project.participations);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Participations'),
        ),
        body: Stack(
          children: <Widget>[
            Container(
              child: _getBody(),
            ),
            _showLoader
                ? const LoaderComponent(
                    text: 'Please wait...',
                  )
                : Container(),
          ],
        ));
  }

  void _noCreatorUser(List<Participations> participations) {
    _participations = [];
    for (var e in participations) {
      if (e.participationType.description != 'Creador') {
        _participations.add(e);
      }
    }
  }

  Widget _getBody() {
    return RefreshIndicator(
      onRefresh: _getProjects,
      child: ListView.builder(
        itemCount: _participations.length,
        itemBuilder: (context, index) {
          return Card(
            child: InkWell(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: <Widget>[
                            _showPhoto(_participations[index]),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              _participations[index].user.fullName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              _participations[index]
                                  .participationType
                                  .description,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                Text(_participations[index].message,
                                    style: const TextStyle(fontSize: 20)),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              _participations[index].activeParticipation
                                  ? 'Active participant'
                                  : 'Pending to accept request',
                              style: const TextStyle(
                                  fontSize: 15, fontStyle: FontStyle.italic),
                              maxLines: 10,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    _showButtons(_participations[index])
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _showPhoto(Participations participation) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: participation.user.imageFullPath.isEmpty
          ? const Image(
              image: AssetImage('assets/noimage.png'),
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CachedNetworkImage(
                imageUrl: participation.user.imageFullPath,
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
                height: 100,
                width: 100,
                placeholder: (context, url) => const Image(
                  image: AssetImage('assets/icono.png'),
                  fit: BoxFit.cover,
                  height: 100,
                  width: 100,
                ),
              ),
            ),
    );
  }

  Widget _showButtons(Participations participation) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              child: const Text('Refuse'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return AppColors.red;
                }),
              ),
              onPressed: () => _deleteParticipation(participation, false),
            ),
          ),
          !participation.activeParticipation
              ? const SizedBox(
                  width: 20,
                )
              : Container(),
          !participation.activeParticipation
              ? Expanded(
                  child: ElevatedButton(
                    child: const Text('Accept'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        return AppColors.darkblue;
                      }),
                    ),
                    onPressed: () => _acceptParticipation(participation, true),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Future<void> _getProjects() async {
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
          message: 'Verify that you are connected to the internet.',
          actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Accept'),
          ]);
      return;
    }

    Response response = await ApiHelper.getProjectById(
        widget.token, widget.project.id.toString());

    setState(() {
      _showLoader = false;
    });

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

    setState(() {
      _noCreatorUser(response.result.participations);
    });
  }

  void _acceptParticipation(Participations participation, bool decision) async {
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
          message: 'Verify that you are connected to the internet.',
          actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Accept'),
          ]);
      return;
    }

    Map<String, dynamic> request = {
      'Id': participation.id,
      'ParticipationTypeId': participation.participationType.id,
      'Message': participation.message,
      'UserName': participation.user.userName,
      'ProjectId': widget.project.id,
      'ActiveParticipation': decision
    };

    Response response = await ApiHelper.put('/api/Participations/',
        participation.id.toString(), request, widget.token.token);

    setState(() {
      _showLoader = false;
    });

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

    setState(() {
      _getProjects();
    });
  }

  void _deleteParticipation(Participations participation, bool decision) async {
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
          message: 'Verify that you are connected to the internet.',
          actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Accept'),
          ]);
      return;
    }

    Response response = await ApiHelper.delete('/api/Participations/',
        participation.id.toString(), widget.token.token);

    setState(() {
      _showLoader = false;
    });

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

    setState(() {});
  }
}
