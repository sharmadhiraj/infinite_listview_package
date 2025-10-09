import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_listview_package/infinite_listview_package.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinite ListView Example',
      home: InfiniteListViewExample(),
    );
  }
}

class InfiniteListViewExample extends StatelessWidget {
  const InfiniteListViewExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Infinite ListView Example")),
      body: InfiniteListViewWidget(),
    );
  }
}

class InfiniteListViewWidget extends InfiniteListView<Post> {
  const InfiniteListViewWidget({Key? key}) : super(key: key);

  @override
  Widget getItemWidget(Post item) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(item.body),
          ],
        ),
      ),
    );
  }

  @override
  Future<List<Post>> getListData(int? pageNumber) async {
    final String url =
        "https://dummyjson.com/posts?skip=${(pageNumber ?? 1 - 1) * 30}";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return Post.parseList(json.decode(response.body)["posts"]);
    } else {
      return Future.error("Something went wrong.");
    }
  }
}

class Post {
  final String title;
  final String body;

  const Post(this.title, this.body);

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      json["title"],
      json["body"],
    );
  }

  static List<Post> parseList(List<dynamic> list) {
    return list.map((i) => Post.fromJson(i)).toList();
  }
}
