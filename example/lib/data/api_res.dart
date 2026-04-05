import 'package:flutter_base/flutter_base.dart';

class ApiResModel<T> {
  final bool success;
  final bool? isEmpty;
  T? data;
  dynamic error;
  List<T>? items;
  final PaginateLinksModel? links;
  final PaginateMetaModel? meta;
  final int code;
  final String? message;

  ApiResModel({
    this.success = false,
    this.isEmpty,
    this.data,
    this.error,
    this.items,
    this.links,
    this.meta,
    this.message,
    this.code = 0,
  });

  ApiResModel<T> mergeType(ApiResModel rs, {T? data, List<T>? items}) {
    return ApiResModel<T>(
      success: rs.success,
      isEmpty: rs.isEmpty,
      data: data,
      error: rs.error,
      items: items,
      links: rs.links,
      meta: rs.meta,
      code: rs.code,
    );
  }

  ApiResModel.fromJson(Map<String, dynamic> json)
      : success = Normalize.initJsonBool(json, 'success') ?? false,
        isEmpty = Normalize.initJsonBool(json, 'is_empty'),
        data = Normalize.initJsonMap(json, 'data'),
        error = Normalize.initJsonMap(json, 'error'),
        items = Normalize.initJsonList(json, 'items'),
        message = Normalize.initJsonString(json, 'message'),
        links = Normalize.initJsonMap(json, '_links', fn: (e) => PaginateLinksModel.fromJson(e)),
        meta = Normalize.initJsonMap(json, '_meta', fn: (e) => PaginateMetaModel.fromJson(e)),
        code = Normalize.initJsonInt(json, 'code') ?? 0;
}

class PaginateLinksModel {
  final String self;
  final String next;
  final String last;

  PaginateLinksModel.fromJson(Map<String, dynamic> json)
      : self = Normalize.initJsonString(json, 'self') ?? '',
        next = Normalize.initJsonString(json, 'next') ?? '',
        last = Normalize.initJsonString(json, 'last') ?? '';
}

class PaginateMetaModel {
  int? totalCount;
  final int? pageCount;
  final int? currentPage;
  final int? nextPage;
  final int? perPage;

  PaginateMetaModel({
    this.totalCount,
    this.pageCount,
    this.currentPage,
    this.nextPage,
    this.perPage,
  });

  PaginateMetaModel.fromJson(Map<String, dynamic> json)
      : totalCount = Normalize.initJsonInt(json, 'total_count'),
        pageCount = Normalize.initJsonInt(json, 'page_count'),
        currentPage = Normalize.initJsonInt(json, 'current_page'),
        nextPage = Normalize.initJsonInt(json, 'next_page'),
        perPage = Normalize.initJsonInt(json, 'per_page');
}
