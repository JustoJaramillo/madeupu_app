import 'package:madeupu_app/models/city.dart';
import 'package:madeupu_app/models/country.dart';
import 'package:madeupu_app/models/participation_type.dart';
import 'package:madeupu_app/models/project.dart';
import 'package:madeupu_app/models/project_category.dart';
import 'package:madeupu_app/models/region.dart';

class Participations {
  int _id = 0;
  List<ParticipationType> _participationType = [];
  String _message = '';
  Project _project = Project(
      id: 0,
      city: City(
          id: 0,
          name: '',
          region: Region(id: 0, name: '', country: Country(id: 0, name: ''))),
      projectCategory: ProjectCategory(id: 0, description: ''),
      name: '',
      website: '',
      address: '',
      beginAt: '',
      description: '',
      imageId: '',
      imageFullPath: '',
      ratingsNumber: 0,
      averageRating: 0);

  Participations(
      {required int id,
      required ParticipationType participationType,
      required String message,
      required Project project}) {
    _id = id;
    _participationType = [];
    _message = message;
    _project = project;
  }

  Participations.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _participationType = json['participationType'];
    _message = json['message'];
    _project = json['project'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['participationType'] = _participationType;
    data['message'] = _message;
    data['project'] = _project.toJson();
    return data;
  }
}
