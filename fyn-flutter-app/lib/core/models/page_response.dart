class PageResponse<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int page;
  final int size;

  PageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.size,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return PageResponse(
      content: (json['content'] as List<dynamic>?)
              ?.map((e) => fromJsonT(e))
              .toList() ??
          [],
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      page: json['page'] ?? 0,
      size: json['size'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'totalElements': totalElements,
      'totalPages': totalPages,
      'page': page,
      'size': size,
    };
  }

  bool get hasNextPage => page < totalPages - 1;
  bool get hasPreviousPage => page > 0;
}














