import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nalsflutter/index.dart';

class MockAppException extends Mock implements AppException {}

void main() {
  late CommonPagingController<String> controller;
  late Future<List<String>> Function(int, bool) mockFetchPage;

  setUp(() {
    mockFetchPage = (pageKey, isInitialLoad) async {
      if (pageKey == 1) {
        return ['item1', 'item2', 'item3'];
      }
      return [];
    };
    controller = CommonPagingController<String>(
      fetchPage: mockFetchPage,
    );
  });

  group('CommonPagingController', () {
    test('initializes with correct initial state', () {
      expect(controller.pagingController.value.pages, null);
      expect(controller.pagingController.value.error, null);
      expect(controller.pagingController.value.hasNextPage, true);
      expect(controller.pagingController.value.isLoading, false);
      controller.dispose();
    });

    test('initializes with provided initial state', () {
      final initialState = PagingState<int, String>(
        pages: [
          ['initial1', 'initial2']
        ],
        keys: [1],
      );

      final controllerWithState = CommonPagingController<String>(
        fetchPage: mockFetchPage,
        initialPageState: initialState,
      );

      expect(controllerWithState.pagingController.value.pages, initialState.pages);
      expect(controllerWithState.pagingController.value.keys, initialState.keys);

      controllerWithState.dispose();
    });

    test('sets error correctly', () {
      final mockError = MockAppException();
      controller.error = mockError;
      expect(controller.pagingController.value.error, mockError);
      controller.dispose();
    });

    test('insertItemAt adds item at correct index', () {
      // First load some data
      controller.pagingController.value = PagingState(
        pages: [
          ['item1', 'item2']
        ],
        keys: [1],
      );

      controller.insertItemAt(
        index: 1,
        item: 'newItem',
      );

      expect(controller.pagingController.value.pages?[0], ['item1', 'newItem', 'item2']);
      controller.dispose();
    });

    test('insertAllItemsAt adds multiple items at correct index', () {
      controller.pagingController.value = PagingState(
        pages: [
          ['item1', 'item2']
        ],
        keys: [1],
      );

      controller.insertAllItemsAt(
        index: 1,
        items: ['newItem1', 'newItem2'],
      );

      expect(
          controller.pagingController.value.pages?[0], ['item1', 'newItem1', 'newItem2', 'item2']);
      controller.dispose();
    });

    test('updateItemAt updates item at correct index', () {
      controller.pagingController.value = PagingState(
        pages: [
          ['item1', 'item2']
        ],
        keys: [1],
      );

      controller.updateItemAt(
        index: 0,
        item: 'updatedItem',
      );

      expect(controller.pagingController.value.pages?[0], ['updatedItem', 'item2']);
      controller.dispose();
    });

    test('removeItemAt removes item at correct index', () {
      controller.pagingController.value = PagingState(
        pages: [
          ['item1', 'item2', 'item3']
        ],
        keys: [1],
      );

      controller.removeItemAt(
        index: 1,
      );

      expect(controller.pagingController.value.pages?[0], ['item1', 'item3']);
      controller.dispose();
    });

    test('removeRange removes items in range', () {
      controller.pagingController.value = PagingState(
        pages: [
          ['item1', 'item2', 'item3', 'item4']
        ],
        keys: [1],
      );

      controller.removeRange(
        start: 1,
        end: 3,
      );

      expect(controller.pagingController.value.pages?[0], ['item1', 'item4']);
      controller.dispose();
    });

    test('clear removes all items from first page', () {
      controller.pagingController.value = PagingState(
        pages: [
          ['item1', 'item2', 'item3']
        ],
        keys: [1],
      );

      controller.clear();

      expect(controller.pagingController.value.pages?[0], []);
      controller.dispose();
    });

    test('item manipulation methods handle null pages gracefully', () {
      controller.pagingController.value = PagingState(
        pages: null,
        keys: null,
      );

      // These should not throw any errors
      controller.insertItemAt(
        index: 0,
        item: 'item',
      );
      controller.insertAllItemsAt(
        index: 0,
        items: ['item1', 'item2'],
      );
      controller.updateItemAt(
        index: 0,
        item: 'item',
      );
      controller.removeItemAt(
        index: 0,
      );
      controller.removeRange(
        start: 0,
        end: 1,
      );
      controller.clear();
      controller.dispose();
    });

    test('refresh triggers new page fetch', () async {
      controller.pagingController.value = PagingState(
        pages: [
          ['item1', 'item2']
        ],
        keys: [1],
      );

      controller.refresh();

      // Wait for the refresh to complete
      await Future.delayed(Duration.zero);

      // The pages should be null after refresh as it clears the state
      expect(controller.pagingController.value.pages, null);
      controller.dispose();
    });
  });
}
