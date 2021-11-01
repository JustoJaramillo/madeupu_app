class Comment {
  int _id = 0;
  String _message = '';
  String _userName = '';
  String _projectId = '';

  Comment(
      {required int id,
      required String message,
      required String userName,
      required String projectId}) {
    _id = id;
    _message = message;
    _userName = userName;
    _projectId = projectId;
  }

  Comment.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _message = json['message'];
    _userName = json['UserName'];
    _projectId = json['ProjectId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['message'] = _message;
    data['UserName'] = _userName;
    data['ProjectId'] = _projectId;
    return data;
  }
}
