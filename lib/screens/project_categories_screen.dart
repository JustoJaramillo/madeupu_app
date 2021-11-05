import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:madeupu_app/components/loader_component.dart';
import 'package:madeupu_app/helpers/api_helper.dart';
import 'package:madeupu_app/models/project_category.dart';
import 'package:madeupu_app/models/response.dart';
import 'package:madeupu_app/models/token.dart';
import 'package:madeupu_app/screens/project_category_screen.dart';

class ProjectCategoriesScreen extends StatefulWidget {
  final Token token;

  // ignore: use_key_in_widget_constructors
  const ProjectCategoriesScreen({required this.token});

  @override
  _ProjectCategoriesScreenState createState() =>
      _ProjectCategoriesScreenState();
}

class _ProjectCategoriesScreenState extends State<ProjectCategoriesScreen> {
  List<ProjectCategory> _projectCategories = [];
  bool _showLoader = false;
  bool _isFiltered = false;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _getProjectCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project categories'),
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

  Future<void> _getProjectCategories() async {
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

  Widget _getContent() {
    return _projectCategories.isEmpty ? _noContent() : _getListView();
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
      onRefresh: _getProjectCategories,
      child: ListView(
        children: _projectCategories.map((e) {
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
    _getProjectCategories();
  }

  void _filter() {
    if (_search.isEmpty) {
      return;
    }

    List<ProjectCategory> filteredList = [];
    for (var projectCategory in _projectCategories) {
      if (projectCategory.description
          .toLowerCase()
          .contains(_search.toLowerCase())) {
        filteredList.add(projectCategory);
      }
    }

    setState(() {
      _projectCategories = filteredList;
      _isFiltered = true;
    });

    Navigator.of(context).pop();
  }

  void _goAdd() async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProjectCategoryScreen(
                  token: widget.token,
                  projectCategory: ProjectCategory(id: 0, description: ''),
                )));
    if (result == 'yes') {
      _getProjectCategories();
    }
  }

  void _goEdit(ProjectCategory projectCategory) async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProjectCategoryScreen(
                  token: widget.token,
                  projectCategory: projectCategory,
                )));
    if (result == 'yes') {
      _getProjectCategories();
    }
  }
}
