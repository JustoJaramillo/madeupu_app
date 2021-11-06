import 'package:madeupu_app/models/city.dart';
import 'package:madeupu_app/models/country.dart';
import 'package:madeupu_app/models/project_category.dart';
import 'package:madeupu_app/models/region.dart';

import 'project_photos.dart';

class Project {
  int id = 0;
  City city = City(
      id: 0,
      name: '',
      region: Region(id: 0, name: '', country: Country(id: 0, name: '')));
  ProjectCategory projectCategory = ProjectCategory(id: 0, description: '');
  String name = '';
  String website = '';
  String address = '';
  String beginAt = '';
  String description = '';
  String imageFullPath = '';
  int ratingsNumber = 0;
  int averageRating = 0;

  Project(
      {required int id,
      required City city,
      required ProjectCategory projectCategory,
      required String name,
      required String website,
      required String address,
      required String beginAt,
      required String description,
      required List<ProjectPhotos> projectPhotos,
      required String imageFullPath,
      required int ratingsNumber,
      required int averageRating}) {
    id = id;
    city = city;
    name = name;
    projectCategory = projectCategory;
    website = website;
    address = address;
    beginAt = beginAt;
    description = description;
    projectPhotos = projectPhotos;
    imageFullPath = imageFullPath;
    ratingsNumber = ratingsNumber;
    averageRating = averageRating;
  }

  Project.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    city = City.fromJson(json['city']);
    name = json['name'];
    projectCategory = ProjectCategory.fromJson(json['projectCategory']);
    website = json['website'];
    address = json['address'];
    beginAt = json['beginAt'];
    description = json['description'];
    imageFullPath = json['imageFullPath'];
    ratingsNumber = json['ratingsNumber'];
    averageRating = json['averageRating'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['city'] = city.toJson();
    data['name'] = name;
    data['projectCategory'] = projectCategory;
    data['website'] = website;
    data['address'] = address;
    data['beginAt'] = beginAt;
    data['description'] = description;
    data['imageFullPath'] = imageFullPath;
    data['ratingsNumber'] = ratingsNumber;
    data['averageRating'] = averageRating;
    return data;
  }
}
