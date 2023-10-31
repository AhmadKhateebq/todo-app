import 'package:intl/intl.dart';
import 'package:todo_app/util/consts.dart';

class ToDo {
  DateTime date;
  String name;
  String? id;
  String? imageUrl;
  int? cid;
  bool? done;

  ToDo({
    required this.date,
    required this.name,
    this.id,
    this.cid,
    this.imageUrl,
    this.done,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': DateFormat('y-MM-dd').format(date),
      'name': name,
      'imageUrl': imageUrl,
      'id': id,
      'cid':cid,
      'done':done
    };
  }

  factory ToDo.fromMap(Map<String, dynamic> map) {
    return ToDo(
        date: DateTime.parse(map['date']),
        name: map['name'],
        imageUrl: map['imageUrl'],
        id: map['id'],
        done: map['done'] ?? false);
  }

  factory ToDo.fromDynamicMap(String key, Map<dynamic, dynamic> map) {
    return ToDo(
        id: key,
        date: DateTime.parse(map['date']),
        name: map['name'],
        imageUrl: map['imageUrl'],
        cid: (map['cid']),
        done: map['done'] ?? false);
  }
  bool isExpired(){
    return date.isBefore(DateTime.now());
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
        imageUrl: value['imageUrl'] ?? noImage,
        date: DateTime.parse(value['date']!),
        done:value['done']??false
    );

  }
}
