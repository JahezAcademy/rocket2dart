const String modelName = "post";
const Map inputJson = {
    "userId": 1,
    "id": 1,
    "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
    "body": "quia et suscipit suscipit recusandae consequuntur expedita et cum"
  };

const String outputModel = """import 'package:mvc_rocket/mvc_rocket.dart';

const String postUserIdField = "userId";
const String postIdField = "id";
const String postTitleField = "title";
const String postBodyField = "body";

class Post extends RocketModel<Post> {
  int? userId;
  int? id;
  String? title;
  String? body;

  Post({
    this.userId,
    this.id,
    this.title,
    this.body,
  });

  @override
  void fromJson(Map<String, dynamic> json, {bool isSub = false}) {
    userId = json[postUserIdField] ?? userId;
    id = json[postIdField] ?? id;
    title = json[postTitleField] ?? title;
    body = json[postBodyField] ?? body;
    super.fromJson(json, isSub: isSub);
  }

  void updateFields({
    int? userIdField,
    int? idField,
    String? titleField,
    String? bodyField,
  }) {
    userId = userIdField ?? userId;
    id = idField ?? id;
    title = titleField ?? title;
    body = bodyField ?? body;
    rebuildWidget();
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[postUserIdField] = userId;
    data[postIdField] = id;
    data[postTitleField] = title;
    data[postBodyField] = body;

    return data;
  }
}
""";

const String outputMultiModel = """import 'package:mvc_rocket/mvc_rocket.dart';

const String postUserIdField = "userId";
const String postIdField = "id";
const String postTitleField = "title";
const String postBodyField = "body";

class Post extends RocketModel<Post> {
  int? userId;
  int? id;
  String? title;
  String? body;

  Post({
    this.userId,
    this.id,
    this.title,
    this.body,
  });

  @override
  void fromJson(Map<String, dynamic> json, {bool isSub = false}) {
    userId = json[postUserIdField] ?? userId;
    id = json[postIdField] ?? id;
    title = json[postTitleField] ?? title;
    body = json[postBodyField] ?? body;
    super.fromJson(json, isSub: isSub);
  }

  void updateFields({
    int? userIdField,
    int? idField,
    String? titleField,
    String? bodyField,
  }) {
    userId = userIdField ?? userId;
    id = idField ?? id;
    title = titleField ?? title;
    body = bodyField ?? body;
    rebuildWidget();
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data[postUserIdField] = userId;
    data[postIdField] = id;
    data[postTitleField] = title;
    data[postBodyField] = body;

    return data;
  }

  @override
  get instance => Post();
}
""";

const String instance = "instance";
const String resultModelName = "Post";
