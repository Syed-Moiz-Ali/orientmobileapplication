class PageResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  const PageResponse({this.content = const [], this.page = 1, this.size = 20, this.totalElements = 0, this.totalPages = 0});
  factory PageResponse.fromJson(Map<String, dynamic> j, T Function(Map<String, dynamic>) fromItem) => PageResponse(
    content: (j['content'] as List<dynamic>?)?.map((e) => fromItem(e as Map<String, dynamic>)).toList() ?? [],
    page: j['page'] as int? ?? 1,
    size: j['size'] as int? ?? 20,
    totalElements: (j['totalElements'] as num?)?.toInt() ?? 0,
    totalPages: j['totalPages'] as int? ?? 0,
  );
}
