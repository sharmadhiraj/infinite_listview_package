import 'package:example/screens/home.dart';
import 'package:flutter/material.dart';

void main() => runApp(const InfiniteListViewExampleApp());

class InfiniteListViewExampleApp extends StatelessWidget {
  const InfiniteListViewExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Infinite ListView Example",
      home: HomeScreen(),
    );
  }
}
