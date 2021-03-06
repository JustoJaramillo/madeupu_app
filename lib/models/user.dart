import 'document_type.dart';

class User {
  String firstName = '';
  String lastName = '';
  DocumentType documentType = DocumentType(id: 0, description: '');
  String document = '';
  String address = '';
  String imageId = '';
  String imageFullPath = '';
  int userType = 1;
  int loginType = 0;
  String? socialImageUrl = '';
  String fullName = '';
  String id = '';
  String userName = '';
  String email = '';
  String countryCode = '';
  String phoneNumber = '';

  User({
    required this.firstName,
    required this.lastName,
    required this.documentType,
    required this.document,
    required this.address,
    required this.imageId,
    required this.imageFullPath,
    required this.userType,
    required this.loginType,
    required this.socialImageUrl,
    required this.fullName,
    required this.id,
    required this.userName,
    required this.email,
    required this.countryCode,
    required this.phoneNumber,
  });

  User.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    documentType = DocumentType.fromJson(json['documentType']);
    document = json['document'];
    address = json['address'];
    imageId = json['imageId'];
    imageFullPath = json['imageFullPath'];
    userType = json['userType'];
    loginType = json['loginType'];
    socialImageUrl = json['socialImageUrl'];
    fullName = json['fullName'];
    id = json['id'];
    userName = json['userName'];
    email = json['email'];
    countryCode = json['countryCode'];
    phoneNumber = json['phoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['documentType'] = documentType.toJson();
    data['document'] = document;
    data['address'] = address;
    data['imageId'] = imageId;
    data['imageFullPath'] = imageFullPath;
    data['userType'] = userType;
    data['loginType'] = loginType;
    data['socialImageUrl'] = socialImageUrl;
    data['fullName'] = fullName;
    data['id'] = id;
    data['userName'] = userName;
    data['email'] = email;
    data['countryCode'] = countryCode;
    data['phoneNumber'] = phoneNumber;
    return data;
  }
}
