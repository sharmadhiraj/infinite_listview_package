## 1.1.0

* Fixed concurrent fetch guard to prevent duplicate pages on fast scrolls
* Added pull-to-refresh support (`enablePullToRefresh()`, defaults to enabled)
* Added empty state widget (`getEmptyStateWidget()`)
* Added separator support (`getSeparatorWidget()`)
* Added `scrollController` parameter for programmatic scrolling
* Added `padding` parameter for list content insets
* Added `physics` parameter for custom scroll physics
* Added `shrinkWrap` parameter for embedding in a `Column` or parent scroll view
* Added `nextPageThreshold` parameter (replaces hardcoded value of 5)
* Added `headerWidget` parameter for a widget that scrolls with the list
* Added `onAllItemsLoaded` callback for end-of-list notification
* Added `onError` callback for external error handling (analytics, crash reporting)

## 1.0.3

* Dynamic per page count value

## 1.0.2

* Implement Infinite ListView Widget
