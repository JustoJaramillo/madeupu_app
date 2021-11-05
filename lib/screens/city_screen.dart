import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:madeupu_app/components/loader_component.dart';
import 'package:madeupu_app/helpers/api_helper.dart';
import 'package:madeupu_app/models/city.dart';
import 'package:madeupu_app/models/region.dart';
import 'package:madeupu_app/models/response.dart';
import 'package:madeupu_app/models/token.dart';

class CityScreen extends StatefulWidget {
  final Token token;
  final City city;
  // ignore: use_key_in_widget_constructors
  const CityScreen({required this.token, required this.city});

  @override
  _CityScreenState createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  bool _showLoader = false;
  String _description = '';
  String _descriptionError = '';
  bool _descriptionShowError = false;
  final TextEditingController _descriptionController = TextEditingController();

  int _regionId = 0;
  String _regionsError = '';
  bool _regionsShowError = false;
  List<Region> _regions = [];

  @override
  void initState() {
    super.initState();
    _getCities();
    _description = widget.city.name;
    _descriptionController.text = _description;
    _regionId = widget.city.region.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.city.id == 0 ? 'New region' : widget.city.name),
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              _showDescription(),
              _showCities(),
              _showButtons(),
            ],
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

  Widget _showDescription() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        autofocus: true,
        controller: _descriptionController,
        decoration: InputDecoration(
          hintText: 'Enter a description...',
          labelText: 'Description',
          errorText: _descriptionShowError ? _descriptionError : null,
          suffixIcon: const Icon(Icons.description),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _description = value;
        },
      ),
    );
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

    Response response = await ApiHelper.getRegions(widget.token);

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
      _regions = response.result;
    });
  }

  Widget _showCities() {
    return Container(
        padding: const EdgeInsets.all(10),
        child: _regions.isEmpty
            ? const Text('Loading regions...')
            : DropdownButtonFormField(
                items: _getComboCountry(),
                value: _regionId,
                onChanged: (option) {
                  setState(() {
                    _regionId = option as int;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Select a region...',
                  labelText: 'Region',
                  errorText: _regionsShowError ? _regionsError : null,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ));
  }

  List<DropdownMenuItem<int>> _getComboCountry() {
    List<DropdownMenuItem<int>> list = [];

    list.add(const DropdownMenuItem(
      child: Text('Select a region...'),
      value: 0,
    ));

    for (var region in _regions) {
      list.add(DropdownMenuItem(
        child: Text(region.name),
        value: region.id,
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
          widget.city.id == 0
              ? Container()
              : const SizedBox(
                  width: 20,
                ),
          widget.city.id == 0
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

  void _save() {
    if (!_validateFields()) {
      return;
    }

    widget.city.id == 0 ? _addRecord() : _saveRecord();
  }

  bool _validateFields() {
    bool isValid = true;

    if (_description.isEmpty) {
      isValid = false;
      _descriptionShowError = true;
      _descriptionError = 'You must enter a description.';
    } else {
      _descriptionShowError = false;
    }

    if (_regionId == 0) {
      isValid = false;
      _regionsShowError = true;
      _regionsError = 'You must select a city .';
    } else {
      _regionsShowError = false;
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

    Map<String, dynamic> request = {
      'name': _description,
      'regionId': _regionId
    };

    Response response =
        await ApiHelper.post('/api/Cities/', request, widget.token.token);

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

    Map<String, dynamic> request = {
      'id': widget.city.id,
      'name': _description,
      'regionId': _regionId
    };

    Response response = await ApiHelper.put(
        '/api/Cities/', widget.city.id.toString(), request, widget.token.token);

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
        '/api/Cities/', widget.city.id.toString(), widget.token.token);

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
