# Infinite Listview Package

A Flutter package for building paginated infinite scroll lists. Handles loading, errors, retries,
and pagination out of the box.

[pub.dev](https://pub.dev/packages/infinite_listview_package) · [install](https://pub.dev/packages/infinite_listview_package/install)

---

## Quick start

Extend `InfiniteListView<T>` and implement two methods:

```dart
class UserList extends InfiniteListView<User> {
  const UserList({super.key});

  @override
  Widget getItemWidget(User item) => ListTile(title: Text(item.name));

  @override
  Future<List<User>> getListData(int? pageNumber) =>
      ApiService.fetchUsers(page: pageNumber);
}
```

Return an empty list from `getListData` to signal end of data. Throw to signal an error — tapping
the error widget retries automatically.

---

## Constructor parameters

| Parameter           | Type                      | Default | Description                                          |
|---------------------|---------------------------|---------|------------------------------------------------------|
| `scrollController`  | `ScrollController?`       | `null`  | Programmatic scrolling (e.g. scroll-to-top)          |
| `padding`           | `EdgeInsetsGeometry?`     | `null`  | Padding around list content                          |
| `physics`           | `ScrollPhysics?`          | `null`  | Scroll physics (e.g. `NeverScrollableScrollPhysics`) |
| `shrinkWrap`        | `bool`                    | `false` | Shrink-wrap list contents                            |
| `nextPageThreshold` | `int`                     | `5`     | Items from end that triggers next page fetch         |
| `headerWidget`      | `Widget?`                 | `null`  | Widget above the first item, scrolls with list       |
| `onAllItemsLoaded`  | `VoidCallback?`           | `null`  | Called once when no more pages remain                |
| `onError`           | `void Function(dynamic)?` | `null`  | Called on every fetch or refresh error               |

---

## Overridable methods

Override any of these to customise the UI:

```
// UI states
Widget getLoadingWidget() // initial full-screen spinner

Widget getPaginationLoadingWidget() // bottom spinner between pages

Widget getEmptyStateWidget() // shown when first page is empty

Widget getErrorWidget(dynamic error) // full-screen error (tap to retry)

Widget getPaginationErrorWidget(dynamic error) // inline error (tap to retry)

// Behaviour
Widget? getSeparatorWidget() // divider between items — null means none

bool enablePullToRefresh() // return false to disable pull-to-refresh
```

---

## Examples

**Dividers between items**

```
@override
Widget? getSeparatorWidget() => const Divider(height: 1);
```

**Nested inside a Column**

```
UserList(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
)
```

**Scroll to top button**

```
final _controller = ScrollController();

UserList(
    scrollController: _controller
)
    
// elsewhere:
_controller.animateTo(
    0,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
);
```

**Error reporting**

```
UserList(
    onError: (error) => FirebaseCrashlytics.instance.recordError(error,null),
)
```

**End-of-list banner**

```
UserList(
    onAllItemsLoaded: () => setState(() => _showEndBanner = true),
)
```

**Header that scrolls with the list**

```
UserList(
    headerWidget: Text('$_total results'),
)
```

---

Feedback and issues welcome on [GitHub](https://github.com).
