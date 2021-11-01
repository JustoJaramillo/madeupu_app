class Country {
  int id = 0;
  String name = '';

  Country({required this.id, required this.name}) {
    id = id;
    name = name;
  }

  Country.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
