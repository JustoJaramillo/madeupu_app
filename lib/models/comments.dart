import 'document_type.dart';
import 'user.dart';

class Comments {
  int id = 0;
  String message = '';
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

  Comments(
      {required this.id,
      required this.message,
      required this.date,
      required this.dateLocal,
      required this.user});

  Comments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    message = json['message'];
    date = json['date'];
    dateLocal = json['dateLocal'];
    user = User.fromJson(json['user']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['message'] = message;
    data['date'] = date;
    data['dateLocal'] = dateLocal;
    data['user'] = user.toJson();
    return data;
  }
}
