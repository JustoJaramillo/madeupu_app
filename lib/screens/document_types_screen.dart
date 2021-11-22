import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:madeupu_app/components/loader_component.dart';
import 'package:madeupu_app/helpers/api_helper.dart';
import 'package:madeupu_app/models/document_type.dart';
import 'package:madeupu_app/models/response.dart';
import 'package:madeupu_app/models/token.dart';

import 'document_type_screen.dart';

class DocumentTypesScreen extends StatefulWidget {
  final Token token;

  const DocumentTypesScreen({Key? key, required this.token}) : super(key: key);

  @override
  _DocumentTypesScreenState createState() => _DocumentTypesScreenState();
}

class _DocumentTypesScreenState extends State<DocumentTypesScreen> {
  List<DocumentType> _documentTypes = [];
  bool _showLoader = false;
  bool _isFiltered = false;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _getDocumentTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Types of document'),
        actions: <Widget>[
          _isFiltered
              ? IconButton(
                  onPressed: _removeFilter, icon: const Icon(Icons.filter_none))
              : IconButton(
                  onPressed: _showFilter, icon: const Icon(Icons.filter_alt))
        ],
      ),
      body: Center(
        child: _showLoader
            ? const LoaderComponent(text: 'Please wait...')
            : _getContent(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _goAdd(),
      ),
    );
  }

  Future<void> _getDocumentTypes() async {
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

    Response response = await ApiHelper.getDocumentTypes();

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
      _documentTypes = response.result;
    });
  }

  Widget _getContent() {
    return _documentTypes.isEmpty ? _noContent() : _getListView();
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Text(
          _isFiltered
              ? 'There are no types of participation with this search criteria.'
              : 'There are no types of participation registered.',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _getListView() {
    return RefreshIndicator(
      onRefresh: _getDocumentTypes,
      child: ListView(
        children: _documentTypes.map((e) {
          return Card(
            child: InkWell(
              onTap: () => _goEdit(e),
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.description,
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        const Icon(Icons.edit_outlined),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showFilter() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: const Text('Filter Document Types'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Write the first letters of the document type'),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                      hintText: 'Search criteria ...',
                      labelText: 'Search',
                      suffixIcon: Icon(Icons.search)),
                  onChanged: (value) {
                    _search = value;
                  },
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => _filter(), child: const Text('Filter')),
            ],
          );
        });
  }

  void _removeFilter() {
    setState(() {
      _isFiltered = false;
    });
    _getDocumentTypes();
  }

  void _filter() {
    if (_search.isEmpty) {
      return;
    }

    List<DocumentType> filteredList = [];
    for (var documentType in _documentTypes) {
      if (documentType.description
          .toLowerCase()
          .contains(_search.toLowerCase())) {
        filteredList.add(documentType);
      }
    }

    setState(() {
      _documentTypes = filteredList;
      _isFiltered = true;
    });

    Navigator.of(context).pop();
  }

  void _goAdd() async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DocumentTypeScreen(
                  token: widget.token,
                  documentType: DocumentType(description: '', id: 0),
                )));
    if (result == 'yes') {
      _getDocumentTypes();
    }
  }

  void _goEdit(DocumentType documentType) async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DocumentTypeScreen(
                  token: widget.token,
                  documentType: documentType,
                )));
    if (result == 'yes') {
      _getDocumentTypes();
    }
  }
}
