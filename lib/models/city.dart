import 'package:madeupu_app/models/country.dart';
import 'package:madeupu_app/models/region.dart';

class City {
  int _id = 0;
  String _name = '';
  Region _region = Region(id: 0, name: '', country: Country(id: 0, name: ''));

  City({required int id, required String name, required Region region}) {
    _id = id;
    _name = name;
    _region = region;
  }

  City.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _region = json['region'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = _id;
    data['name'] = _name;
    data['region'] = _region.toJson();

    return data;
  }
}
