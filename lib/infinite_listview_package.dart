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
  const InfiniteListView({
    Key? key,
    this.scrollController,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.nextPageThreshold = 5,
    this.headerWidget,
    this.onAllItemsLoaded,
    this.onError,
  }) : super(key: key);

  /// Optional controller for programmatic scrolling (e.g. scroll-to-top).
  final ScrollController? scrollController;

  /// Optional padding around the list content.
  final EdgeInsetsGeometry? padding;

  /// Optional scroll physics (e.g. NeverScrollableScrollPhysics for nested scrolling).
  final ScrollPhysics? physics;

  /// Whether the list should shrink-wrap its contents. Defaults to false.
  final bool shrinkWrap;

  /// How many items from the end triggers the next page fetch. Defaults to 5.
  final int nextPageThreshold;

  /// Optional widget rendered above the first list item, scrolling with the list.
  final Widget? headerWidget;

  /// Called once when the last page is reached and there are no more items.
  final VoidCallback? onAllItemsLoaded;

  /// Called whenever a fetch or refresh fails, with the error as argument.
  final void Function(dynamic error)? onError;

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

  /// Widget shown when the initial data load succeeds but returns an empty list.
  Widget getEmptyStateWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          "No items found.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  /// Return a widget to show between list items. Null shows no separator.
  Widget? getSeparatorWidget() => null;

  /// Return false to disable pull-to-refresh. Defaults to true.
  bool enablePullToRefresh() => true;

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
  int? _pageNumber = 1;
  final List<T> _listData = [];
  bool _hasMore = true;
  bool _isLoading = false;
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
    return widget.getEmptyStateWidget();
  }

  /// Builds the paginated list with inline pagination loading/error at the bottom.
  Widget _buildList() {
    final hasHeader = widget.headerWidget != null;
    final offset = hasHeader ? 1 : 0;

    Widget itemBuilder(BuildContext context, int index) {
      if (hasHeader && index == 0) return widget.headerWidget!;
      final dataIndex = index - offset;
      final targetIndex = _listData.length - widget.nextPageThreshold;
      if (_hasMore &&
          !_hasError &&
          (dataIndex == targetIndex || (targetIndex < 0 && dataIndex == 0))) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
      }
      if (dataIndex == _listData.length) return _buildPaginationFooter();
      return widget.getItemWidget(_listData[dataIndex]);
    }

    final separator = widget.getSeparatorWidget();
    final itemCount = _listData.length + 1 + offset;
    final list = separator == null
        ? ListView.builder(
            controller: widget.scrollController,
            padding: widget.padding,
            physics: widget.physics,
            shrinkWrap: widget.shrinkWrap,
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          )
        : ListView.separated(
            controller: widget.scrollController,
            padding: widget.padding,
            physics: widget.physics,
            shrinkWrap: widget.shrinkWrap,
            itemCount: itemCount,
            separatorBuilder: (_, index) {
              if (hasHeader && index == 0) return const SizedBox.shrink();
              return separator;
            },
            itemBuilder: itemBuilder,
          );

    if (!widget.enablePullToRefresh()) return list;
    return RefreshIndicator(onRefresh: _refresh, child: list);
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

  /// Resets all state and reloads from page 1.
  Future<void> _refresh() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final results = await widget.getListData(1);
      setState(() {
        _listData
          ..clear()
          ..addAll(results);
        _pageNumber = results.isEmpty ? 1 : 2;
        _hasMore = results.isNotEmpty;
        _hasError = false;
        _encounteredError = null;
        _isLoading = false;
      });
    } catch (error) {
      widget.onError?.call(error);
      setState(() {
        _isLoading = false;
        if (_listData.isEmpty) {
          _encounteredError = error;
          _hasError = true;
        }
      });
    }
  }

  /// Resets error state and retries the last failed fetch.
  void _retry() {
    setState(() => _hasError = false);
    _fetchData();
  }

  /// Fetches the next page of data and appends it to [_listData].
  /// No-op if there are no more pages or a fetch is already in progress.
  Future<void> _fetchData() async {
    if (!_hasMore || _isLoading || _hasError) return;
    setState(() => _isLoading = true);
    try {
      final results = await widget.getListData(_pageNumber);
      setState(() {
        _isLoading = false;
        if (results.isEmpty) {
          _hasMore = false;
          widget.onAllItemsLoaded?.call();
        } else {
          _pageNumber = _pageNumber! + 1;
          _listData.addAll(results);
        }
      });
    } catch (error) {
      widget.onError?.call(error);
      setState(() {
        _encounteredError = error;
        _isLoading = false;
        _hasError = true;
      });
    }
  }
}
