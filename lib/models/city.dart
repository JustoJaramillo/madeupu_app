import 'package:madeupu_app/models/country.dart';
import 'package:madeupu_app/models/region.dart';

class City {
  int id = 0;
  String name = '';
  Region region = Region(id: 0, name: '', country: Country(id: 0, name: ''));

  City({required int id, required String name, required Region region});

  City.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    region = Region.fromJson(json['region']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['region'] = region.toJson();

    return data;
  }
}
