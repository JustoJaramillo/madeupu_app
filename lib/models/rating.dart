import 'package:madeupu_app/models/document_type.dart';
import 'package:madeupu_app/models/user.dart';

class Ratings {
  int id = 0;
  int rate = 0;
  String date = '';
  String dateLocal = '';
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

  Ratings(
      {required this.id,
      required this.rate,
      required this.date,
      required this.dateLocal,
      required this.user});

  Ratings.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    rate = json['rate'];
    date = json['date'];
    dateLocal = json['dateLocal'];
    user = User.fromJson(json['user']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['rate'] = rate;
    data['date'] = date;
    data['dateLocal'] = dateLocal;
    data['user'] = user.toJson();
    return data;
  }
}
