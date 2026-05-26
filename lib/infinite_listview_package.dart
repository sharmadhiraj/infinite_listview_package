/// A Flutter library for implementing infinite scroll ListView widgets.
library infinite_listview_package;

import 'package:flutter/material.dart';

/// Abstract base class for building paginated infinite scroll ListViews.
///
/// Extend this class and implement [getItemWidget] and [getListData].
/// Override other methods to customise loading, error, and pagination UI.
///
/// Type parameter [T] represents the data model for each list item.
abstract class InfiniteListView<T> extends StatefulWidget {
  const InfiniteListView({Key? key}) : super(key: key);

  @override
  State<InfiniteListView<T>> createState() => _InfiniteListViewState<T>();

  /// Builds a single list item widget for the given [item].
  Widget getItemWidget(T item);

  /// Fetches a page of items for the given [pageNumber].
  /// Return an empty list to signal end of data.
  Future<List<T>> getListData(int? pageNumber);

  /// Widget shown during initial data load.
  Widget getLoadingWidget() => const Center(child: CircularProgressIndicator());

  /// Widget shown at the bottom of the list while fetching the next page.
  Widget getPaginationLoadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Widget shown when the initial data load fails.
  /// Wrap with [InkWell] is handled internally — tap triggers a retry.
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

  /// Widget shown at the bottom of the list when pagination fails.
  /// Wrap with [InkWell] is handled internally — tap triggers a retry.
  Widget getPaginationErrorWidget(dynamic error) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Something went wrong! Tap to try again.'),
      ),
    );
  }
}

class _InfiniteListViewState<T> extends State<InfiniteListView<T>> {
  /// Number of items from the end at which the next page fetch is triggered.
  static const int _nextPageThreshold = 5;

  int? _pageNumber = 1;
  final List<T?> _listData = [];
  bool _hasMore = true;
  bool _isLoading = true;
  bool _hasError = false;
  dynamic _encounteredError;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (_listData.isEmpty) {
      return _buildEmptyState();
    }
    return _buildList();
  }

  /// Handles the initial empty state — loading spinner or full-screen error.
  Widget _buildEmptyState() {
    if (_isLoading) return widget.getLoadingWidget();
    if (_hasError) {
      return InkWell(
        onTap: _retry,
        child: widget.getErrorWidget(_encounteredError),
      );
    }
    return const SizedBox.shrink();
  }

  /// Builds the paginated list with inline pagination loading/error at the bottom.
  Widget _buildList() {
    return ListView.builder(
      itemCount: _listData.length + 1,
      itemBuilder: (context, index) {
        if (index == _listData.length - _nextPageThreshold) {
          _fetchData();
        }

        // Last slot — pagination indicator or end-of-list
        if (index == _listData.length) {
          return _buildPaginationFooter();
        }

        return widget.getItemWidget(_listData[index] as T);
      },
    );
  }

  /// Builds the footer widget shown after the last item.
  Widget _buildPaginationFooter() {
    if (!_hasMore) return const SizedBox.shrink();
    if (_hasError) {
      return InkWell(
        onTap: _retry,
        child: widget.getPaginationErrorWidget(_encounteredError),
      );
    }
    return widget.getPaginationLoadingWidget();
  }

  /// Resets error state and retries the last failed fetch.
  void _retry() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _fetchData();
  }

  /// Fetches the next page of data and appends it to [_listData].
  /// No-op if there are no more pages or a fetch is already in progress.
  Future<void> _fetchData() async {
    if (!_hasMore || _isLoading) return;

    try {
      final results = await widget.getListData(_pageNumber);
      setState(() {
        _isLoading = false;
        if (results.isEmpty) {
          _hasMore = false;
        } else {
          _pageNumber = _pageNumber! + 1;
          _listData.addAll(results as List<T?>);
        }
      });
    } catch (error) {
      setState(() {
        _encounteredError = error;
        _isLoading = false;
        _hasError = true;
      });
    }
  }
}
