import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:madeupu_app/components/loader_component.dart';
import 'package:madeupu_app/helpers/api_helper.dart';
import 'package:madeupu_app/models/document_type.dart';
import 'package:madeupu_app/models/response.dart';
import 'package:madeupu_app/models/token.dart';

class DocumentTypeScreen extends StatefulWidget {
  final Token token;
  final DocumentType documentType;

  const DocumentTypeScreen(
      {Key? key, required this.token, required this.documentType})
      : super(key: key);

  @override
  _DocumentTypeScreenState createState() => _DocumentTypeScreenState();
}

class _DocumentTypeScreenState extends State<DocumentTypeScreen> {
  bool _showLoader = false;
  String _description = '';
  String _descriptionError = '';
  bool _descriptionShowError = false;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _description = widget.documentType.description;
    _descriptionController.text = _description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.documentType.id == 0
            ? 'New type of document'
            : widget.documentType.description),
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              _showDescription(),
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
          widget.documentType.id == 0
              ? Container()
              : const SizedBox(
                  width: 20,
                ),
          widget.documentType.id == 0
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

    widget.documentType.id == 0 ? _addRecord() : _saveRecord();
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
      'description': _description,
    };

    Response response = await ApiHelper.post(
        '/api/DocumentTypes/', request, widget.token.token);

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
      'id': widget.documentType.id,
      'description': _description,
    };

    Response response = await ApiHelper.put('/api/DocumentTypes/',
        widget.documentType.id.toString(), request, widget.token.token);

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

    Response response = await ApiHelper.delete('/api/DocumentTypes/',
        widget.documentType.id.toString(), widget.token.token);

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
