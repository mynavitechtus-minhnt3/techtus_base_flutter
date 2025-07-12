import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../../../index.dart';

final loadMoreUsersExecutorProvider = Provider<LoadMoreUsersExecutor>(
  (ref) => getIt.get<LoadMoreUsersExecutor>(),
);

class LoadMoreUsersParams extends LoadMoreParams {
  LoadMoreUsersParams();
}

@Injectable()
class LoadMoreUsersExecutor extends LoadMoreExecutor<ApiUserData, LoadMoreUsersParams> {
  LoadMoreUsersExecutor(this.appApiService);

  final AppApiService appApiService;

  @protected
  @override
  Future<PagedList<ApiUserData>> action({
    required int page,
    required int limit,
    required LoadMoreUsersParams? params,
  }) async {
    final response = await appApiService.getUsers(page: page, limit: limit);

    return PagedList(data: response?.results ?? [], next: response?.next);
  }
}
