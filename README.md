# Infinite ListView 

Flutter <a href="https://pub.dev/packages/infinite_listview_package" target="_blank">package</a> that provides infinite scroll listiview widget.

## Getting Started
1. <a href="https://pub.dev/packages/infinite_listview_package#-installing-tab-" target="_blank">Installation Guide</a>
2. <a href="https://pub.dev/packages/infinite_listview_package#-example-tab-" target="_blank">Example</a>
<hr/>

## Usage Guide
1. Create a class extending `InfiniteListView<T>`, where T is type of item on list you are going to build.
2. Implement method `getItemWidget(T item)`, this method should return widget for single item on list.
3. Implement method `getListData(int pageNumber)`, this is `async` method and should return list of item according to pageNumber in parameter. This method should return `Future.error(...)` in case of error.
4. Override method `getPerPageCount()` to configure items per page. (Default is 10)
5. Override method `getNextPageThreshold()` to configure when should request for next page made. Value 5 means request for next page is made when user is seeing last 5 items on list. (Default is 5)
6. Override method `getLoadingWidget()`, `getPaginationLoadingWidget()`, `getErrorWidget(dynamic error)`, `getPaginationErrorWidget(dynamic error)` to customize widgets while request in progress and error.

