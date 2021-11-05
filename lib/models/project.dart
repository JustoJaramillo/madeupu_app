import 'package:madeupu_app/models/city.dart';
import 'package:madeupu_app/models/country.dart';
import 'package:madeupu_app/models/project_category.dart';
import 'package:madeupu_app/models/region.dart';

class Project {
  int _id = 0;
  City _city = City(
      id: 0,
      name: '',
      region: Region(id: 0, name: '', country: Country(id: 0, name: '')));
  ProjectCategory _projectCategory = ProjectCategory(id: 0, description: '');
  String _name = '';
  String _website = '';
  String _address = '';
  String _beginAt = '';
  String _description = '';
  String _imageId = '';
  String _imageFullPath = '';
  int _ratingsNumber = 0;
  int _averageRating = 0;

  Project(
      {required int id,
      required City city,
      required ProjectCategory projectCategory,
      required String name,
      required String website,
      required String address,
      required String beginAt,
      required String description,
      required String imageId,
      required String imageFullPath,
      required int ratingsNumber,
      required int averageRating}) {
    _id = id;
    _city = city;
    _name = name;
    _projectCategory = projectCategory;
    _website = website;
    _address = address;
    _beginAt = beginAt;
    _description = description;
    _imageId = imageId;
    _imageFullPath = imageFullPath;
    _ratingsNumber = ratingsNumber;
    _averageRating = averageRating;
  }

  Project.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _city = json['city'];
    _name = json['name'];
    _projectCategory = json['projectCategory'];
    _website = json['website'];
    _address = json['address'];
    _beginAt = json['beginAt'];
    _description = json['description'];
    _imageId = json['imageId'];
    _imageFullPath = json['imageFullPath'];
    _ratingsNumber = json['ratingsNumber'];
    _averageRating = json['averageRating'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['city'] = _city.toJson();
    data['name'] = _name;
    data['projectCategory'] = _projectCategory;
    data['website'] = _website;
    data['address'] = _address;
    data['beginAt'] = _beginAt;
    data['description'] = _description;
    data['imageId'] = _imageId;
    data['imageFullPath'] = _imageFullPath;
    data['ratingsNumber'] = _ratingsNumber;
    data['averageRating'] = _averageRating;
    return data;
  }
}
