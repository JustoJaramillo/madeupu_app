import 'dart:convert';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madeupu_app/components/loader_component.dart';
import 'package:madeupu_app/helpers/api_helper.dart';
import 'package:madeupu_app/models/city.dart';
import 'package:madeupu_app/models/project.dart';
import 'package:madeupu_app/models/project_category.dart';
import 'package:madeupu_app/models/response.dart';
import 'package:madeupu_app/models/token.dart';

import 'package:date_field/date_field.dart';

class ProjectScreen extends StatefulWidget {
  final Token token;
  final Project project;

  const ProjectScreen({Key? key, required this.token, required this.project})
      : super(key: key);

  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  bool _showLoader = false;

  bool _photoChanged = false;
  late XFile _image;

  String _projectName = '';
  String _projectNameError = '';
  bool _projectNameShowError = false;
  final TextEditingController _projectNameController = TextEditingController();

  int _projectCategoryId = 0;
  String _projectCategoriesError = '';
  bool _projectCategoriesShowError = false;
  List<ProjectCategory> _projectCategories = [];

  String _projectWebsite = '';
  String _projectWebsiteError = '';
  bool _projectWebsiteShowError = false;
  final TextEditingController _projectWebsiteController =
      TextEditingController();

  String _projectAddress = '';
  String _projectAddressError = '';
  bool _projectAddressShowError = false;
  final TextEditingController _projectAddressController =
      TextEditingController();

  DateTime _projectBeginAt = DateTime.now();

  String _projectDescription = '';
  String _projectDescriptionError = '';
  bool _projectDescriptionShowError = false;
  final TextEditingController _projectDescriptionController =
      TextEditingController();

  String _projectVideo = '';
  String _projectVideoError = '';
  bool _projectVideoShowError = false;
  final TextEditingController _projectVideoController = TextEditingController();

  String _userName = '';

  int _cityId = 0;
  String _citiesError = '';
  bool _citiesShowError = false;
  List<City> _cities = [];

  @override
  void initState() {
    super.initState();
    _getCities();
    _getCategories();
    _projectName = widget.project.name;
    _projectWebsite = widget.project.website;
    _projectAddress = widget.project.address;
    _projectBeginAt = widget.project.beginAt.isEmpty
        ? _projectBeginAt
        : DateTime.parse(widget.project.beginAt).toUtc();
    _projectDescription = widget.project.description;
    _projectVideo = widget.project.video;

    _projectNameController.text = _projectName;
    _projectWebsiteController.text = _projectWebsite;
    _projectAddressController.text = _projectAddress;
    _projectDescriptionController.text = _projectDescription;
    _projectVideoController.text = _projectVideo;

    _userName = widget.token.user.userName;
    _projectCategoryId = widget.project.projectCategory.id;
    _cityId = widget.project.city.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.project.id == 0 ? 'New project' : widget.project.name),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _showPhoto(),
                _showProjectName(),
                _showCategories(),
                _showProjectWebsite(),
                _showProjectAddress(),
                _showProjectBeginAt(),
                _showCities(),
                _showProjectDescription(),
                _showProjectVideo(),
                _showButtons(),
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
    );
  }

  Widget _showProjectName() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        autofocus: true,
        controller: _projectNameController,
        decoration: InputDecoration(
          hintText: 'Enter a name...',
          labelText: 'Project name',
          errorText: _projectNameShowError ? _projectNameError : null,
          suffixIcon: const Icon(Icons.description),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _projectName = value;
        },
      ),
    );
  }

  void _selectPicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photoChanged = true;
        _image = image;
      });
    }
  }

  Widget _showProjectWebsite() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        autofocus: true,
        controller: _projectWebsiteController,
        decoration: InputDecoration(
          hintText: 'Enter a website url...',
          labelText: 'Website',
          errorText: _projectWebsiteShowError ? _projectWebsiteError : null,
          suffixIcon: const Icon(Icons.description),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _projectWebsite = value;
        },
      ),
    );
  }

  Widget _showProjectAddress() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        autofocus: true,
        controller: _projectAddressController,
        decoration: InputDecoration(
          hintText: 'Enter a project address...',
          labelText: 'Project address',
          errorText: _projectAddressShowError ? _projectAddressError : null,
          suffixIcon: const Icon(Icons.description),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _projectAddress = value;
        },
      ),
    );
  }

  Widget _showProjectBeginAt() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: DateTimeFormField(
        decoration: const InputDecoration(
          hintStyle: TextStyle(color: Colors.black45),
          errorStyle: TextStyle(color: Colors.redAccent),
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.event_note),
          labelText: 'Project start date',
          hintText: 'Enter a project start date...',
        ),
        mode: DateTimeFieldPickerMode.date,
        autovalidateMode: AutovalidateMode.always,
        validator: (e) {
          (e?.isUtc ?? 0) == 0 ? "You must enter a date" : null;
        },
        initialValue: _projectBeginAt,
        onDateSelected: (DateTime value) {
          _projectBeginAt = value;
        },
      ),
    );
  }

  Widget _showProjectDescription() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Scrollbar(
        child: TextField(
          minLines: 2,
          keyboardType: TextInputType.multiline,
          maxLines: 8,
          autofocus: true,
          controller: _projectDescriptionController,
          decoration: InputDecoration(
            hintText: 'Enter a project description...',
            labelText: 'Project description',
            errorText:
                _projectDescriptionShowError ? _projectDescriptionError : null,
            suffixIcon: const Icon(Icons.description),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: (value) {
            _projectDescription = value;
          },
        ),
      ),
    );
  }

  Widget _showProjectVideo() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        autofocus: true,
        controller: _projectVideoController,
        decoration: InputDecoration(
          hintText: 'Enter a project pitch video link...',
          labelText: 'Project pitch video link',
          errorText: _projectVideoShowError ? _projectVideoError : null,
          suffixIcon: const Icon(Icons.description),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _projectVideo = value;
        },
      ),
    );
  }

  Widget _showPhoto() {
    return Stack(children: <Widget>[
      InkWell(
        onTap: () => _selectPicture(),
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          child: widget.project.imageFullPath.isEmpty && !_photoChanged
              ? const Image(
                  image: AssetImage('assets/noimage.png'),
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: _photoChanged
                      ? Image.file(
                          File(_image.path),
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        )
                      : FadeInImage(
                          placeholder: const AssetImage('assets/logo.png'),
                          image: NetworkImage(widget.project.imageFullPath),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover),
                ),
        ),
      ),
    ]);
  }

  Future<void> _getCities() async {
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

    Response response = await ApiHelper.getCities(widget.token);

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
      _cities = response.result;
    });
  }

  Future<void> _getCategories() async {
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

    Response response = await ApiHelper.getProjectCategories(widget.token);

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
      _projectCategories = response.result;
    });
  }

  Widget _showCities() {
    return Container(
        padding: const EdgeInsets.all(10),
        child: _cities.isEmpty
            ? const Text('Loading cities...')
            : DropdownButtonFormField(
                items: _getComboCities(),
                value: _cityId,
                onChanged: (option) {
                  setState(() {
                    _cityId = option as int;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Select a city...',
                  labelText: 'City',
                  errorText: _citiesShowError ? _citiesError : null,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ));
  }

  Widget _showCategories() {
    return Container(
        padding: const EdgeInsets.all(10),
        child: _projectCategories.isEmpty
            ? const Text('Loading categories...')
            : DropdownButtonFormField(
                items: _getComboCategories(),
                value: _projectCategoryId,
                onChanged: (option) {
                  setState(() {
                    _projectCategoryId = option as int;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Select a category...',
                  labelText: 'Category',
                  errorText: _projectCategoriesShowError
                      ? _projectCategoriesError
                      : null,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ));
  }

  List<DropdownMenuItem<int>> _getComboCities() {
    List<DropdownMenuItem<int>> list = [];

    list.add(const DropdownMenuItem(
      child: Text('Select a city...'),
      value: 0,
    ));

    for (var city in _cities) {
      list.add(DropdownMenuItem(
        child: Text(city.name),
        value: city.id,
      ));
    }

    return list;
  }

  List<DropdownMenuItem<int>> _getComboCategories() {
    List<DropdownMenuItem<int>> list = [];

    list.add(const DropdownMenuItem(
      child: Text('Select a category...'),
      value: 0,
    ));

    for (var category in _projectCategories) {
      list.add(DropdownMenuItem(
        child: Text(category.description),
        value: category.id,
      ));
    }

    return list;
  }

  Widget _showButtons() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              child: const Text('Save'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return const Color(0xFF120E43);
                }),
              ),
              onPressed: () => _save(),
            ),
          ),
          widget.project.id == 0
              ? Container()
              : const SizedBox(
                  width: 20,
                ),
          widget.project.id == 0
              ? Container()
              : Expanded(
                  child: ElevatedButton(
                    child: const Text('Delete'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        return const Color(0xFFB4161B);
                      }),
                    ),
                    onPressed: () => _confirmDelete(),
                  ),
                ),
        ],
      ),
    );
  }

  void _confirmDelete() async {
    var response = await showAlertDialog(
        context: context,
        title: 'Confirmation',
        message: 'Are you sure you want to delete the record?',
        actions: <AlertDialogAction>[
          const AlertDialogAction(key: 'no', label: 'No'),
          const AlertDialogAction(key: 'yes', label: 'Yes'),
        ]);

    if (response == 'yes') {
      _deleteRecord();
    }
  }

  void _deleteRecord() async {
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
        '/api/Projects/', widget.project.id.toString(), widget.token.token);

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

    Navigator.pop(context, 'yes');
  }

  void _save() {
    if (!_validateFields()) {
      return;
    }

    widget.project.id == 0 ? _addRecord() : _saveRecord();
  }

  bool _validateFields() {
    bool isValid = true;

    if (_projectName.isEmpty) {
      isValid = false;
      _projectNameShowError = true;
      _projectNameError = 'You must enter a project name.';
    } else {
      _projectNameShowError = false;
    }

    if (_projectWebsite.isEmpty) {
      isValid = false;
      _projectWebsiteShowError = true;
      _projectWebsiteError = 'You must enter a website url.';
    } else {
      _projectWebsiteShowError = false;
    }

    if (_projectAddress.isEmpty) {
      isValid = false;
      _projectAddressShowError = true;
      _projectAddressError = 'You must enter a project address.';
    } else {
      _projectAddressShowError = false;
    }

    if (_projectDescription.isEmpty) {
      isValid = false;
      _projectDescriptionShowError = true;
      _projectDescriptionError = 'You must enter a project description.';
    } else {
      _projectDescriptionShowError = false;
    }

    if (_projectVideo.isEmpty) {
      isValid = false;
      _projectVideoShowError = true;
      _projectVideoError = 'You must enter a project pitch video link.';
    } else {
      _projectVideoShowError = false;
    }

    if (_projectCategoryId == 0) {
      isValid = false;
      _projectCategoriesShowError = true;
      _projectCategoriesError = 'You must select a category .';
    } else {
      _projectCategoriesShowError = false;
    }

    if (_cityId == 0) {
      isValid = false;
      _citiesShowError = true;
      _citiesError = 'You must select a city .';
    } else {
      _citiesShowError = false;
    }

    setState(() {});
    return isValid;
  }

  _addRecord() async {
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

    String base64image = '';
    if (_photoChanged) {
      List<int> imageBytes = await _image.readAsBytes();
      base64image = base64Encode(imageBytes);
    }

    Map<String, dynamic> request = {
      'CityId': _cityId,
      'ProjectCategoryId': _projectCategoryId,
      'Name': _projectName,
      'Website': _projectWebsite,
      'Address': _projectAddress,
      'BeginAt': _projectBeginAt.toString().substring(0, 10),
      'Description': _projectDescription,
      'Image': base64image,
      'UserName': _userName,
      'video': _projectVideo
    };

    Response response =
        await ApiHelper.post('/api/Projects', request, widget.token.token);

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

    Navigator.pop(context, 'yes');
  }

  _saveRecord() async {
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

    String base64image = '';
    if (_photoChanged) {
      List<int> imageBytes = await _image.readAsBytes();
      base64image = base64Encode(imageBytes);
    }

    Map<String, dynamic> request = {
      'Id': widget.project.id,
      'CityId': _cityId,
      'ProjectCategoryId': _projectCategoryId,
      'Name': _projectName,
      'Website': _projectWebsite,
      'Address': _projectAddress,
      'BeginAt': _projectBeginAt.toString().substring(0, 10),
      'Description': _projectDescription,
      'Image': base64image,
      'UserName': _userName,
      'video': _projectVideo
    };

    Response response = await ApiHelper.put('/api/Projects/',
        widget.project.id.toString(), request, widget.token.token);

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

    Navigator.pop(context, 'yes');
  }
}
