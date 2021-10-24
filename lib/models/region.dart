import 'package:madeupu_app/models/country.dart';

class Region {
  int _id = 0;
  String _name = '';
  Country _country = Country(id: 0, name: '');

  Region({required int id, required String name, required Country country}) {
    _id = id;
    _name = name;
    _country = country;
  }

  Region.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _country = json['country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = _id;
    data['name'] = _name;
    data['country'] = _country.toJson();
    return data;
  }
}
