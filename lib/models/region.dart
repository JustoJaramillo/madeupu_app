import 'package:madeupu_app/models/country.dart';

class Region {
  int id = 0;
  String name = '';
  Country country = Country(id: 0, name: '');

  Region({required int id, required String name, required Country country}) {
    id = id;
    name = name;
    country = country;
  }

  Region.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    country = Country.fromJson(json['country']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['country'] = country.toJson();
    return data;
  }
}
