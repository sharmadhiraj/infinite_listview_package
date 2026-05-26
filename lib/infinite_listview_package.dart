/// A Flutter library for implementing infinite scroll listview widgets.
library infinite_listview_package;

import 'package:flutter/material.dart';

/// An abstract class for creating infinite scroll listview widgets.
abstract class InfiniteListView<T> extends StatefulWidget {
  const InfiniteListView({Key? key}) : super(key: key);

  @override
  State<InfiniteListView<T>> createState() => _InfiniteListViewState<T>();

  /// Returns a widget representing a single item in the list.
  Widget getItemWidget(T item);

  /// Retrieves a list of items for the specified page number.
  Future<List<T>> getListData(int? pageNumber);

  /// Returns the widget to display while the initial data is being loaded.
  Widget getLoadingWidget() => const Center(child: CircularProgressIndicator());

  /// Returns the widget to display while additional data is being loaded for pagination.
  Widget getPaginationLoadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Returns the widget to display in case of an error while loading initial data.
  Widget getErrorWidget(dynamic error) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          "Something went wrong! Tap to try again.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  /// Returns the widget to display in case of an error while loading additional data for pagination.
  Widget getPaginationErrorWidget(dynamic error) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text("Something went wrong! Tap to try again."),
      ),
    );
  }
}

class _InfiniteListViewState<T> extends State<InfiniteListView<T>> {
  late bool _hasMore;
  late bool _error;
  late bool _loading;
  int? _pageNumber;
  late List<T?> _listData;
  final int _nextPageThreshold = 5;
  dynamic _encounteredError;

  @override
  void initState() {
    super.initState();
    _hasMore = true;
    _error = false;
    _loading = true;
    _pageNumber = 1;
    _listData = [];
    fetchPhotos();
  }

  @override
  Widget build(BuildContext context) {
    if (_listData.isEmpty) {
      if (_loading) {
        return widget.getLoadingWidget();
      } else if (_error) {
        return InkWell(
          onTap: () => retry(),
          child: widget.getErrorWidget(_encounteredError),
        );
      }
    } else {
      return ListView.builder(
        itemCount: _listData.length + 1,
        itemBuilder: (context, index) {
          if (index == _listData.length - _nextPageThreshold) {
            fetchPhotos();
          }
          if (index == _listData.length) {
            if (!_hasMore) {
              return const SizedBox.shrink();
            } else if (_error) {
              return InkWell(
                onTap: () => retry(),
                child: widget.getPaginationErrorWidget(_encounteredError),
              );
            } else {
              return widget.getPaginationLoadingWidget();
            }
          }
          return widget.getItemWidget(_listData[index] as T);
        },
      );
    }
    return Container();
  }

  void retry() {
    setState(() {
      _loading = true;
      _error = false;
      fetchPhotos();
    });
  }

  Future<void> fetchPhotos() async {
    if (!_hasMore) return;
    await widget.getListData(_pageNumber).then((value) {
      setState(() {
        _loading = false;
        if (value.isEmpty) {
          _hasMore = false;
        } else {
          _pageNumber = _pageNumber! + 1;
          _listData.addAll(value as List<T?>);
        }
      });
    }).catchError((error) {
      setState(() {
        _encounteredError = error;
        _loading = false;
        _error = true;
      });
    });
  }
}
