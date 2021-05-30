import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_listview_package/infinite_listview_package.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinite ListView Example',
      home: InfiniteListViewExample(),
    );
  }
}

class InfiniteListViewExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Infinite ListView Example")),
      body: InfiniteListViewWidget(),
    );
  }
}

class InfiniteListViewWidget extends InfiniteListView<Photo> {
  @override
  Widget getItemWidget(Photo item) {
    return Card(
      child: Column(
        children: <Widget>[
          Image.network(
            item.thumbnailUrl!,
            fit: BoxFit.fitWidth,
            width: double.infinity,
            height: 160,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              item.title!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Future<List<Photo>> getListData(int? pageNumber) async {
    final response = await http.get(Uri.parse(
        "https://jsonplaceholder.typicode.com/photos?_page=$pageNumber"));
    if (response.statusCode == 200)
      return Photo.parseList(json.decode(response.body));
    else
      return Future.error("Something went wrong.");
  }
}

class Photo {
  final String? title;
  final String? thumbnailUrl;

  Photo(
    this.title,
    this.thumbnailUrl,
  );

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(json["title"], json["thumbnailUrl"]);
  }

  static List<Photo> parseList(List<dynamic> list) {
    return list.map((i) => Photo.fromJson(i)).toList();
  }
}
