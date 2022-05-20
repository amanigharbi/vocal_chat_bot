import 'dart:convert';

List<Documents> postFromJson(String str) =>
    List<Documents>.from(json.decode(str).map((x) => Documents.fromJson(x)));

class Documents {
  Documents({
    required this.name,
    required this.file,
  });

  String file;
  String name;

  factory Documents.fromJson(Map<String, dynamic> json) => Documents(
        name: json["name"] as String,
        file: json["file"] as String,
      );
}
