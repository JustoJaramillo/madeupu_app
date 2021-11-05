import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:madeupu_app/components/loader_component.dart';
import 'package:madeupu_app/helpers/api_helper.dart';
import 'package:madeupu_app/models/country.dart';
import 'package:madeupu_app/models/response.dart';
import 'package:madeupu_app/models/token.dart';
import 'package:madeupu_app/screens/country_screen.dart';

class CountriesScreen extends StatefulWidget {
  final Token token;

  // ignore: use_key_in_widget_constructors
  const CountriesScreen({required this.token});

  @override
  _CountriesScreenState createState() => _CountriesScreenState();
}

class _CountriesScreenState extends State<CountriesScreen> {
  List<Country> _countries = [];
  bool _showLoader = false;
  bool _isFiltered = false;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _getCountries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contries'),
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

  Future<void> _getCountries() async {
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

    Response response = await ApiHelper.getCountries(widget.token);

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
      _countries = response.result;
    });
  }

  Widget _getContent() {
    return _countries.isEmpty ? _noContent() : _getListView();
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
      onRefresh: _getCountries,
      child: ListView(
        children: _countries.map((e) {
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
                          e.name,
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
    _getCountries();
  }

  void _filter() {
    if (_search.isEmpty) {
      return;
    }

    List<Country> filteredList = [];
    for (var country in _countries) {
      if (country.name.toLowerCase().contains(_search.toLowerCase())) {
        filteredList.add(country);
      }
    }

    setState(() {
      _countries = filteredList;
      _isFiltered = true;
    });

    Navigator.of(context).pop();
  }

  void _goAdd() async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CountryScreen(
                  token: widget.token,
                  country: Country(id: 0, name: ''),
                )));
    if (result == 'yes') {
      _getCountries();
    }
  }

  void _goEdit(Country country) async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CountryScreen(
                  token: widget.token,
                  country: country,
                )));
    if (result == 'yes') {
      _getCountries();
    }
  }
}
