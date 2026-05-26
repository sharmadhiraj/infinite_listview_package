import 'dart:convert';

import 'package:example/models/post.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_listview_package/infinite_listview_package.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Infinite ListView Example")),
      body: const InfiniteListViewWidget(),
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
              style: const TextStyle(
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
    debugPrint("Fetching url: $url");
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return Post.parseList(json.decode(response.body)["posts"]);
    } else {
      return Future.error("Something went wrong.");
    }
  }
}
