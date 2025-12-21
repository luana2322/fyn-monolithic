/// Search filter for user discovery
class SearchFilter {
  final String? keyword; // Search by name, interests, etc.
  final String? gender; // MALE, FEMALE, OTHER, null = all
  final int? minAge;
  final int? maxAge;
  final String? location;
  final int? maxDistanceKm;

  SearchFilter({
    this.keyword,
    this.gender,
    this.minAge,
    this.maxAge,
    this.location,
    this.maxDistanceKm,
  });

  /// Check if any filter is active
  bool get hasActiveFilters =>
      (keyword != null && keyword!.isNotEmpty) ||
      gender != null ||
      minAge != null ||
      maxAge != null ||
      (location != null && location!.isNotEmpty) ||
      maxDistanceKm != null;

  /// Convert to query parameters
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (keyword != null && keyword!.isNotEmpty) params['keyword'] = keyword;
    if (gender != null) params['gender'] = gender;
    if (minAge != null) params['minAge'] = minAge;
    if (maxAge != null) params['maxAge'] = maxAge;
    if (location != null && location!.isNotEmpty) {
      params['location'] = location;
    }
    if (maxDistanceKm != null) params['maxDistanceKm'] = maxDistanceKm;
    return params;
  }

  /// Create a copy with modifications
  SearchFilter copyWith({
    String? keyword,
    String? gender,
    int? minAge,
    int? maxAge,
    String? location,
    int? maxDistanceKm,
    bool clearKeyword = false,
    bool clearGender = false,
    bool clearMinAge = false,
    bool clearMaxAge = false,
    bool clearLocation = false,
    bool clearMaxDistance = false,
  }) {
    return SearchFilter(
      keyword: clearKeyword ? null : (keyword ?? this.keyword),
      gender: clearGender ? null : (gender ?? this.gender),
      minAge: clearMinAge ? null : (minAge ?? this.minAge),
      maxAge: clearMaxAge ? null : (maxAge ?? this.maxAge),
      location: clearLocation ? null : (location ?? this.location),
      maxDistanceKm: clearMaxDistance ? null : (maxDistanceKm ?? this.maxDistanceKm),
    );
  }

  /// Reset all filters
  SearchFilter clear() {
    return SearchFilter();
  }
}
