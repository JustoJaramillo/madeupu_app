class ProjectPhotos {
  int id = 0;
  String imageId = '';
  String imageFullPath = '';

  ProjectPhotos(
      {required this.id, required this.imageId, required this.imageFullPath});

  ProjectPhotos.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    imageId = json['imageId'];
    imageFullPath = json['imageFullPath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['imageId'] = imageId;
    data['imageFullPath'] = imageFullPath;
    return data;
  }
}
