class Rating {
  int _id = 0;
  int _rate = 0;
  String _userName = '';
  String _projectId = '';

  Rating(
      {required int id,
      required int rate,
      required String userName,
      required String projectId}) {
    _id = id;
    _rate = rate;
    _userName = userName;
    _projectId = projectId;
  }

  Rating.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _rate = json['rate'];
    _userName = json['UserName'];
    _projectId = json['ProjectId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['rate'] = _rate;
    data['UserName'] = _userName;
    data['ProjectId'] = _projectId;
    return data;
  }
}
