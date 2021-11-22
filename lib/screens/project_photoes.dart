import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madeupu_app/components/loader_component.dart';
import 'package:madeupu_app/helpers/api_helper.dart';
import 'package:madeupu_app/helpers/app_colors.dart';
import 'package:madeupu_app/models/project.dart';
import 'package:madeupu_app/models/response.dart';
import 'package:madeupu_app/models/token.dart';
import 'package:madeupu_app/screens/projects_by_user.dart';

class ProjectPhotoes extends StatefulWidget {
  final Token token;
  final Project project;
  const ProjectPhotoes({Key? key, required this.token, required this.project})
      : super(key: key);

  @override
  _ProjectPhotoesState createState() => _ProjectPhotoesState();
}

class _ProjectPhotoesState extends State<ProjectPhotoes> {
  bool _showLoader = false;
  bool _photoChanged = false;
  late XFile _image;
  int _current = 0;
  final CarouselController _carouselController = CarouselController();
  bool _somethingNew = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _somethingNew
            ? Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProjectsByUser(token: widget.token)),
              )
            : Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add images'),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _showPhoto(),
                  _showProjectName(),
                  Container(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: const Text(
                      'Project Images',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                  _showPhotosCarousel(),
                ],
              ),
            ),
            _showLoader
                ? const LoaderComponent(
                    text: 'Please wait...',
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  _showPhoto() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        child: widget.project.imageFullPath.isEmpty
            ? const Image(
                image: AssetImage('assets/noimage.png'),
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: FadeInImage(
                    placeholder: const AssetImage('assets/logo.png'),
                    image: NetworkImage(widget.project.imageFullPath),
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _showProjectName() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            widget.project.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          )
        ],
      ),
    );
  }

  Widget _showPhotosCarousel() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
                height: 300,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                }),
            carouselController: _carouselController,
            items: widget.project.projectPhotos.map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: i.imageFullPath,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          fit: BoxFit.cover,
                          height: 300,
                          width: 300,
                          placeholder: (context, url) => const Image(
                            image: AssetImage('assets/logo.png'),
                            fit: BoxFit.cover,
                            height: 300,
                            width: 300,
                          ),
                        ),
                      ));
                },
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.project.projectPhotos.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _carouselController.animateToPage(entry.key),
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                ),
              );
            }).toList(),
          ),
          _showImageButtons()
        ],
      ),
    );
  }

  Widget _showImageButtons() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const <Widget>[
                  Icon(Icons.add_a_photo),
                  Text('Add photo'),
                ],
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return AppColors.darkblue;
                }),
              ),
              onPressed: () => _goAddPhoto(),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: ElevatedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const <Widget>[
                  Icon(Icons.delete),
                  Text('Delete photo'),
                ],
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return AppColors.red;
                }),
              ),
              onPressed: () => _confirmDeletePhoto(),
            ),
          ),
        ],
      ),
    );
  }

  void _goAddPhoto() async {
    var response = await showAlertDialog(
        context: context,
        title: 'Confirmation',
        message: 'Would you like to add from gallery?',
        actions: <AlertDialogAction>[
          const AlertDialogAction(key: 'no', label: 'No'),
          const AlertDialogAction(key: 'yes', label: 'Yes'),
        ]);

    if (response == 'no') {
      return;
    } else {
      await _selectPicture();
    }

    if (_photoChanged) {
      _addPicture();
    }
  }

  Future<void> _selectPicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photoChanged = true;
        _image = image;
      });
    }
  }

  void _confirmDeletePhoto() async {
    var response = await showAlertDialog(
        context: context,
        title: 'Confirmation',
        message: '¿Are you sure you wanto to delete the last photo added?',
        actions: <AlertDialogAction>[
          const AlertDialogAction(key: 'no', label: 'No'),
          const AlertDialogAction(key: 'yes', label: 'Sí'),
        ]);

    if (response == 'yes') {
      _deletePhoto();
    }
  }

  void _addPicture() async {
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

    List<int> imageBytes = await _image.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    Map<String, dynamic> request = {
      'Id': 0,
      'ProjectId': widget.project.id,
      'image': base64Image
    };

    Response response = await ApiHelper.post(
        '/api/ProjectPhotoes', request, widget.token.token);

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
    _somethingNew = true;
    Navigator.pop(context, 'yes');
  }

  void _deletePhoto() async {
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

    Response response = await ApiHelper.delete(
        '/api/ProjectPhotoes/',
        widget.project.projectPhotos[widget.project.projectPhotos.length - 1].id
            .toString(),
        widget.token.token);

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

    _somethingNew = true;
    Navigator.pop(context, 'yes');
  }
}
