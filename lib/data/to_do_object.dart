class ToDo {
  DateTime date;
  String name;
  String? id;
  String? imageUrl;
  int? cid;

  ToDo(
      {required this.date,
      required this.name,
      this.id,
      this.cid,
      this.imageUrl});

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'name': name,
      'imageUrl': imageUrl,
      'id': id,
    };
  }

  factory ToDo.fromMap(Map<String, dynamic> map) {
    return ToDo(
      date: DateTime.parse(map['date']),
      name: map['name'],
      imageUrl: map['imageUrl'],
      id: map['id'],
    );
  }

  @override
  String toString() {
    return 'ToDo{date: $date, name: $name, id: $id, imageUrl: $imageUrl, cid: $cid}';
  }

  factory ToDo.fromJson(String key, Map<String, dynamic> value) {
    return ToDo(
        id: key,
        cid: value['cid']!,
        name: value['name']!,
        imageUrl: value['imageUrl'] ??
            "https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg",
        date: DateTime.parse(value['date']!));
  }
}
