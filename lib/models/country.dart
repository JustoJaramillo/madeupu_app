class Country {
  int _id = 0;
  String _name = '';

  Country({required int id, required String name}) {
    _id = id;
    _name = name;
  }

  Country.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = _id;
    data['name'] = _name;
    return data;
  }
}
