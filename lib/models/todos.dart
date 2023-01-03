


class Todo{

Todo({required this.title, required this.datesTime});

Todo.fromJson(Map<String, dynamic> json)
: title = json['title'],
datesTime = DateTime.parse(json['datetime']);

final String title;
final DateTime datesTime;

toJson() {
  return {
    'title' : title,
    'datetime' : datesTime.toIso8601String(),
  };
}


}


