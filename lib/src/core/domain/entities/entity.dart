enum ResStatus { none, success, failure }

class ResEntity {
  final ResStatus status;
  final bool success;
  final bool? isEmpty;
  final InfoEmptyEntity? information;
  dynamic error;
  final int code;

  ResEntity({
    this.status = ResStatus.none,
    this.success = false,
    this.isEmpty,
    this.information,
    this.error,
    this.code = 0,
  });
}

typedef ItemResSuccess<T> = void Function(
  T? data,
);
typedef ItemResError<T> = void Function(dynamic error);
typedef ItemsResError<T> = void Function(dynamic error);

class ItemResEntity<T> extends ResEntity {
  final T? data;

  ItemResEntity({
    required super.status,
    super.success,
    super.information,
    super.isEmpty,
    super.error,
    super.code,
    this.data,
  });

  void callSuccess(ItemResSuccess<T> call) {
    if (status.isNone() || status.isFailure()) return;

    call.call(data);
  }

  void onError(ItemResError call) {
    if (status.isNone() || status.isSuccess()) return;

    call.call(error);
  }
}

class ItemsResEntity<T> extends ResEntity {
  final List<T>? items;
  final PaginateLinksEntity? links;
  final PaginateMetaEntity? meta;

  ItemsResEntity({
    required super.status,
    super.success,
    super.information,
    super.isEmpty,
    super.error,
    super.code,
    this.items,
    this.links,
    this.meta,
  });

  void onError(ItemsResError call) {
    if (status.isNone() || status.isSuccess()) return;

    call.call(error);
  }
}

class InfoEmptyEntity {
  final String? name;
  final String? description;

  InfoEmptyEntity({
    this.name,
    this.description,
  });
}

extension ResStatusX on ResStatus {
  bool isSuccess() => this == ResStatus.success;

  bool isFailure() => this == ResStatus.failure;

  bool isNone() => this == ResStatus.none;
}

class PaginateLinksEntity {
  final String self;
  final String next;
  final String last;

  PaginateLinksEntity({
    this.self = '',
    this.next = '',
    this.last = '',
  });
}

class PaginateMetaEntity {
  int? totalCount;
  final int? pageCount;
  final int? currentPage;
  final int? nextPage;
  final int? perPage;

  PaginateMetaEntity({
    this.totalCount,
    this.pageCount,
    this.currentPage,
    this.nextPage,
    this.perPage,
  });
}
