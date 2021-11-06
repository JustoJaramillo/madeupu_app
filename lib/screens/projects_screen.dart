import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:madeupu_app/components/loader_component.dart';
import 'package:madeupu_app/helpers/api_helper.dart';
import 'package:madeupu_app/models/project.dart';
import 'package:madeupu_app/models/response.dart';
import 'package:madeupu_app/models/token.dart';
import 'package:madeupu_app/screens/project_screen.dart';

class ProjectsScreen extends StatefulWidget {
  final Token token;
  final bool projectByUsername;

  // ignore: use_key_in_widget_constructors
  const ProjectsScreen({required this.token, required this.projectByUsername});

  @override
  _ProjectsScreenState createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Project> projects = [];
  bool _showLoader = false;

  @override
  void initState() {
    super.initState();
    _getProjects();
  }

  @override
  Widget build(BuildContext context) {
    return widget.projectByUsername ? _myProjects() : _projects();
  }

  Widget _myProjects() {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Projects'),
        ),
        body: Stack(children: [
          _getBody(),
          _showLoader
              ? const LoaderComponent(text: 'Please wait...')
              : Container(),
        ]));
  }

  Widget _projects() {
    return Stack(
      children: [
        _getBody(),
        _showLoader
            ? const LoaderComponent(text: 'Please wait...')
            : Container(),
      ],
    );
  }

  Widget _showPhoto(Project project) {
    return Stack(children: <Widget>[
      Container(
        margin: const EdgeInsets.only(top: 10),
        child: project.imageFullPath.isEmpty
            ? const Image(
                image: AssetImage('assets/noimage.png'),
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: CachedNetworkImage(
                  imageUrl: project.imageFullPath,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                  height: 120,
                  width: 120,
                  placeholder: (context, url) => const Image(
                    image: AssetImage('assets/icono.png'),
                    fit: BoxFit.cover,
                    height: 120,
                    width: 120,
                  ),
                ),
              ),
      ),
    ]);
  }

  Widget _getBody() {
    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, index) {
        return Card(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProjectScreen(
                        token: widget.token, project: projects[index])),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [Icon(Icons.reorder_rounded)]),
                  _showPhoto(projects[index]),
                  Center(
                    child: Text(
                      projects[index].name,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Text(
                    projects[index].description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

    Response response = widget.projectByUsername
        ? await ApiHelper.getProjectsByUser(
            widget.token, widget.token.user.userName)
        : await ApiHelper.getProjects();

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
      projects = response.result;
    });
  }
}
