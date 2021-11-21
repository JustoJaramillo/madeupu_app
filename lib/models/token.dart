import 'package:madeupu_app/models/user.dart';

import 'document_type.dart';

class Token {
  String token = '';
  String expiration = '';
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

  Token({required this.token, required this.expiration, required this.user});

  Token.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    expiration = json['expiration'];
    user = User.fromJson(json['user']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['expiration'] = expiration;
    data['user'] = user.toJson();
    return data;
  }
}
