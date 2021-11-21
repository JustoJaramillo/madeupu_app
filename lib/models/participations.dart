import 'package:madeupu_app/models/document_type.dart';
import 'package:madeupu_app/models/participation_type.dart';
import 'package:madeupu_app/models/user.dart';

class Participations {
  int id = 0;
  ParticipationType participationType =
      ParticipationType(id: 0, description: '');
  String message = '';
  bool activeParticipation = false;
  User user = User(
      firstName: '',
      lastName: '',
      documentType: DocumentType(id: 0, description: ''),
      document: '',
      address: '',
      imageId: '',
      imageFullPath: '',
      userType: 0,
      loginType: 0,
      socialImageUrl: '',
      fullName: '',
      id: '',
      userName: '',
      email: '',
      countryCode: '',
      phoneNumber: '');

  Participations(
      {required this.id,
      required this.participationType,
      required this.message,
      required this.activeParticipation,
      required this.user});

  Participations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    participationType = ParticipationType.fromJson(json['participationType']);
    message = json['message'];
    activeParticipation = json['activeParticipation'];
    user = User.fromJson(json['user']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['participationType'] = participationType.toJson();
    data['message'] = message;
    data['activeParticipation'] = activeParticipation;
    data['user'] = user.toJson();
    return data;
  }
}
