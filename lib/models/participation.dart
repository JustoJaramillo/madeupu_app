import 'package:madeupu_app/models/city.dart';
import 'package:madeupu_app/models/country.dart';
import 'package:madeupu_app/models/participation_type.dart';
import 'package:madeupu_app/models/project.dart';
import 'package:madeupu_app/models/project_category.dart';
import 'package:madeupu_app/models/region.dart';

class Participations {
  int id = 0;
  List<ParticipationType> participationType = [];
  String message = '';
  bool activateParticipation = false;
  Project project = Project(
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
      projectPhotos: [],
      imageFullPath: '',
      ratingsNumber: 0,
      averageRating: 0);

  Participations(
      {required int id,
      required ParticipationType participationType,
      required String message,
      required bool activateParticipation,
      required Project project}) {
    id = id;
    participationType = [] as ParticipationType;
    message = message;
    activateParticipation = activateParticipation;
    project = project;
  }

  Participations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    json['participationType'].forEach((v) {
      participationType.add(ParticipationType.fromJson(v));
    });
    message = json['message'];
    activateParticipation = json['activateParticipation'];
    project = json['project'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['participationType'] =
        participationType.map((v) => v.toJson()).toList();
    data['message'] = message;
    data['activateParticipation'] = activateParticipation;
    data['project'] = project.toJson();
    return data;
  }
}
