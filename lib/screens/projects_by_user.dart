import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:madeupu_app/components/loader_component.dart';
import 'package:madeupu_app/helpers/api_helper.dart';
import 'package:madeupu_app/helpers/app_colors.dart';
import 'package:madeupu_app/models/city.dart';
import 'package:madeupu_app/models/country.dart';
import 'package:madeupu_app/models/project.dart';
import 'package:madeupu_app/models/project_category.dart';
import 'package:madeupu_app/models/region.dart';
import 'package:madeupu_app/models/response.dart';
import 'package:madeupu_app/models/token.dart';
import 'package:madeupu_app/screens/participation_screen.dart';

import 'project_screen.dart';

class ProjectsByUser extends StatefulWidget {
  final Token token;
  // ignore: use_key_in_widget_constructors
  const ProjectsByUser({required this.token});

  @override
  _ProjectsByUserState createState() => _ProjectsByUserState();
}

class _ProjectsByUserState extends State<ProjectsByUser> {
  List<Project> projects = [];
  bool _showLoader = false;

  @override
  void initState() {
    super.initState();
    _getProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
      ),
      body: Stack(children: [
        _getBody(),
        _showLoader
            ? const LoaderComponent(text: 'Please wait...')
            : Container(),
      ]),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add), onPressed: () => _goAdd()),
    );
  }

  void _goAdd() async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProjectScreen(
                  token: widget.token,
                  project: Project(
                      id: 0,
                      city: City(
                          id: 0,
                          name: '',
                          region: Region(
                              id: 0,
                              name: '',
                              country: Country(id: 0, name: ''))),
                      projectCategory: ProjectCategory(id: 0, description: ''),
                      name: '',
                      website: '',
                      address: '',
                      beginAt: '',
                      description: '',
                      imageFullPath: '',
                      ratingsNumber: 0,
                      averageRating: 0,
                      participations: [],
                      projectPhotos: [],
                      ratings: [],
                      comments: [],
                      video: '',
                      videoCode: ''),
                )));
    if (result == 'yes') {
      _getProjects();
    }
  }

  void _goEdit(Project project) async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProjectScreen(
                  token: widget.token,
                  project: project,
                )));
    if (result == 'yes') {
      _getProjects();
    }
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
    return RefreshIndicator(
      onRefresh: _getProjects,
      child: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          return Card(
            child: InkWell(
              onTap: () {
                _goEdit(projects[index]);
              },
              child: Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [Icon(Icons.reorder_rounded)]),
                    _showPhoto(projects[index]),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Text(
                        projects[index].name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      projects[index].description,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Total ratings: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${projects[index].ratingsNumber}',
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              'Average Rating: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${projects[index].averageRating}',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      '${projects[index].city.region.name}, ${projects[index].city.region.country.name}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    _showButtons(projects[index])
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _showButtons(Project project) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              child: const Text('Add images'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return AppColors.blue;
                }),
              ),
              onPressed: () {},
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: ElevatedButton(
              child: const Text('Participations'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return AppColors.darkblue;
                }),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ParticipationScreen(
                          project: project, token: widget.token)),
                );
              },
            ),
          ),
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

    Response response = await ApiHelper.getProjectsByUser(
        widget.token, widget.token.user.userName);

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
