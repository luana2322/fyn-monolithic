// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meetup_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MeetupModel _$MeetupModelFromJson(Map<String, dynamic> json) {
  return _MeetupModel.fromJson(json);
}

/// @nodoc
mixin _$MeetupModel {
  String get id => throw _privateConstructorUsedError;
  UserSummary get organizer => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  MeetType get meetType => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get location =>
      throw _privateConstructorUsedError; // Made nullable to handle null from backend
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  int? get durationMinutes => throw _privateConstructorUsedError;
  int get maxParticipants => throw _privateConstructorUsedError;
  int get acceptedCount => throw _privateConstructorUsedError;
  int get pendingMatchCount => throw _privateConstructorUsedError;
  MeetupStatus get status => throw _privateConstructorUsedError;
  ConfirmationStatus get confirmationStatus =>
      throw _privateConstructorUsedError;
  double? get distanceKm => throw _privateConstructorUsedError;
  bool get userHasApplied => throw _privateConstructorUsedError;
  MatchStatus? get userMatchStatus => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MeetupModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MeetupModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeetupModelCopyWith<MeetupModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeetupModelCopyWith<$Res> {
  factory $MeetupModelCopyWith(
          MeetupModel value, $Res Function(MeetupModel) then) =
      _$MeetupModelCopyWithImpl<$Res, MeetupModel>;
  @useResult
  $Res call(
      {String id,
      UserSummary organizer,
      String title,
      String? description,
      MeetType meetType,
      String? category,
      String? location,
      double latitude,
      double longitude,
      DateTime scheduledAt,
      DateTime? expiresAt,
      int? durationMinutes,
      int maxParticipants,
      int acceptedCount,
      int pendingMatchCount,
      MeetupStatus status,
      ConfirmationStatus confirmationStatus,
      double? distanceKm,
      bool userHasApplied,
      MatchStatus? userMatchStatus,
      DateTime? createdAt});

  $UserSummaryCopyWith<$Res> get organizer;
}

/// @nodoc
class _$MeetupModelCopyWithImpl<$Res, $Val extends MeetupModel>
    implements $MeetupModelCopyWith<$Res> {
  _$MeetupModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeetupModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? organizer = null,
    Object? title = null,
    Object? description = freezed,
    Object? meetType = null,
    Object? category = freezed,
    Object? location = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? scheduledAt = null,
    Object? expiresAt = freezed,
    Object? durationMinutes = freezed,
    Object? maxParticipants = null,
    Object? acceptedCount = null,
    Object? pendingMatchCount = null,
    Object? status = null,
    Object? confirmationStatus = null,
    Object? distanceKm = freezed,
    Object? userHasApplied = null,
    Object? userMatchStatus = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      organizer: null == organizer
          ? _value.organizer
          : organizer // ignore: cast_nullable_to_non_nullable
              as UserSummary,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      meetType: null == meetType
          ? _value.meetType
          : meetType // ignore: cast_nullable_to_non_nullable
              as MeetType,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      maxParticipants: null == maxParticipants
          ? _value.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      acceptedCount: null == acceptedCount
          ? _value.acceptedCount
          : acceptedCount // ignore: cast_nullable_to_non_nullable
              as int,
      pendingMatchCount: null == pendingMatchCount
          ? _value.pendingMatchCount
          : pendingMatchCount // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MeetupStatus,
      confirmationStatus: null == confirmationStatus
          ? _value.confirmationStatus
          : confirmationStatus // ignore: cast_nullable_to_non_nullable
              as ConfirmationStatus,
      distanceKm: freezed == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double?,
      userHasApplied: null == userHasApplied
          ? _value.userHasApplied
          : userHasApplied // ignore: cast_nullable_to_non_nullable
              as bool,
      userMatchStatus: freezed == userMatchStatus
          ? _value.userMatchStatus
          : userMatchStatus // ignore: cast_nullable_to_non_nullable
              as MatchStatus?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of MeetupModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserSummaryCopyWith<$Res> get organizer {
    return $UserSummaryCopyWith<$Res>(_value.organizer, (value) {
      return _then(_value.copyWith(organizer: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MeetupModelImplCopyWith<$Res>
    implements $MeetupModelCopyWith<$Res> {
  factory _$$MeetupModelImplCopyWith(
          _$MeetupModelImpl value, $Res Function(_$MeetupModelImpl) then) =
      __$$MeetupModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      UserSummary organizer,
      String title,
      String? description,
      MeetType meetType,
      String? category,
      String? location,
      double latitude,
      double longitude,
      DateTime scheduledAt,
      DateTime? expiresAt,
      int? durationMinutes,
      int maxParticipants,
      int acceptedCount,
      int pendingMatchCount,
      MeetupStatus status,
      ConfirmationStatus confirmationStatus,
      double? distanceKm,
      bool userHasApplied,
      MatchStatus? userMatchStatus,
      DateTime? createdAt});

  @override
  $UserSummaryCopyWith<$Res> get organizer;
}

/// @nodoc
class __$$MeetupModelImplCopyWithImpl<$Res>
    extends _$MeetupModelCopyWithImpl<$Res, _$MeetupModelImpl>
    implements _$$MeetupModelImplCopyWith<$Res> {
  __$$MeetupModelImplCopyWithImpl(
      _$MeetupModelImpl _value, $Res Function(_$MeetupModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MeetupModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? organizer = null,
    Object? title = null,
    Object? description = freezed,
    Object? meetType = null,
    Object? category = freezed,
    Object? location = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? scheduledAt = null,
    Object? expiresAt = freezed,
    Object? durationMinutes = freezed,
    Object? maxParticipants = null,
    Object? acceptedCount = null,
    Object? pendingMatchCount = null,
    Object? status = null,
    Object? confirmationStatus = null,
    Object? distanceKm = freezed,
    Object? userHasApplied = null,
    Object? userMatchStatus = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$MeetupModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      organizer: null == organizer
          ? _value.organizer
          : organizer // ignore: cast_nullable_to_non_nullable
              as UserSummary,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      meetType: null == meetType
          ? _value.meetType
          : meetType // ignore: cast_nullable_to_non_nullable
              as MeetType,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      maxParticipants: null == maxParticipants
          ? _value.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      acceptedCount: null == acceptedCount
          ? _value.acceptedCount
          : acceptedCount // ignore: cast_nullable_to_non_nullable
              as int,
      pendingMatchCount: null == pendingMatchCount
          ? _value.pendingMatchCount
          : pendingMatchCount // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MeetupStatus,
      confirmationStatus: null == confirmationStatus
          ? _value.confirmationStatus
          : confirmationStatus // ignore: cast_nullable_to_non_nullable
              as ConfirmationStatus,
      distanceKm: freezed == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double?,
      userHasApplied: null == userHasApplied
          ? _value.userHasApplied
          : userHasApplied // ignore: cast_nullable_to_non_nullable
              as bool,
      userMatchStatus: freezed == userMatchStatus
          ? _value.userMatchStatus
          : userMatchStatus // ignore: cast_nullable_to_non_nullable
              as MatchStatus?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MeetupModelImpl implements _MeetupModel {
  const _$MeetupModelImpl(
      {required this.id,
      required this.organizer,
      required this.title,
      this.description,
      required this.meetType,
      this.category,
      this.location,
      required this.latitude,
      required this.longitude,
      required this.scheduledAt,
      this.expiresAt,
      this.durationMinutes,
      required this.maxParticipants,
      required this.acceptedCount,
      required this.pendingMatchCount,
      required this.status,
      required this.confirmationStatus,
      this.distanceKm,
      required this.userHasApplied,
      this.userMatchStatus,
      this.createdAt});

  factory _$MeetupModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeetupModelImplFromJson(json);

  @override
  final String id;
  @override
  final UserSummary organizer;
  @override
  final String title;
  @override
  final String? description;
  @override
  final MeetType meetType;
  @override
  final String? category;
  @override
  final String? location;
// Made nullable to handle null from backend
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final DateTime scheduledAt;
  @override
  final DateTime? expiresAt;
  @override
  final int? durationMinutes;
  @override
  final int maxParticipants;
  @override
  final int acceptedCount;
  @override
  final int pendingMatchCount;
  @override
  final MeetupStatus status;
  @override
  final ConfirmationStatus confirmationStatus;
  @override
  final double? distanceKm;
  @override
  final bool userHasApplied;
  @override
  final MatchStatus? userMatchStatus;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'MeetupModel(id: $id, organizer: $organizer, title: $title, description: $description, meetType: $meetType, category: $category, location: $location, latitude: $latitude, longitude: $longitude, scheduledAt: $scheduledAt, expiresAt: $expiresAt, durationMinutes: $durationMinutes, maxParticipants: $maxParticipants, acceptedCount: $acceptedCount, pendingMatchCount: $pendingMatchCount, status: $status, confirmationStatus: $confirmationStatus, distanceKm: $distanceKm, userHasApplied: $userHasApplied, userMatchStatus: $userMatchStatus, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeetupModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.organizer, organizer) ||
                other.organizer == organizer) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.meetType, meetType) ||
                other.meetType == meetType) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants) &&
            (identical(other.acceptedCount, acceptedCount) ||
                other.acceptedCount == acceptedCount) &&
            (identical(other.pendingMatchCount, pendingMatchCount) ||
                other.pendingMatchCount == pendingMatchCount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.confirmationStatus, confirmationStatus) ||
                other.confirmationStatus == confirmationStatus) &&
            (identical(other.distanceKm, distanceKm) ||
                other.distanceKm == distanceKm) &&
            (identical(other.userHasApplied, userHasApplied) ||
                other.userHasApplied == userHasApplied) &&
            (identical(other.userMatchStatus, userMatchStatus) ||
                other.userMatchStatus == userMatchStatus) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        organizer,
        title,
        description,
        meetType,
        category,
        location,
        latitude,
        longitude,
        scheduledAt,
        expiresAt,
        durationMinutes,
        maxParticipants,
        acceptedCount,
        pendingMatchCount,
        status,
        confirmationStatus,
        distanceKm,
        userHasApplied,
        userMatchStatus,
        createdAt
      ]);

  /// Create a copy of MeetupModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeetupModelImplCopyWith<_$MeetupModelImpl> get copyWith =>
      __$$MeetupModelImplCopyWithImpl<_$MeetupModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MeetupModelImplToJson(
      this,
    );
  }
}

abstract class _MeetupModel implements MeetupModel {
  const factory _MeetupModel(
      {required final String id,
      required final UserSummary organizer,
      required final String title,
      final String? description,
      required final MeetType meetType,
      final String? category,
      final String? location,
      required final double latitude,
      required final double longitude,
      required final DateTime scheduledAt,
      final DateTime? expiresAt,
      final int? durationMinutes,
      required final int maxParticipants,
      required final int acceptedCount,
      required final int pendingMatchCount,
      required final MeetupStatus status,
      required final ConfirmationStatus confirmationStatus,
      final double? distanceKm,
      required final bool userHasApplied,
      final MatchStatus? userMatchStatus,
      final DateTime? createdAt}) = _$MeetupModelImpl;

  factory _MeetupModel.fromJson(Map<String, dynamic> json) =
      _$MeetupModelImpl.fromJson;

  @override
  String get id;
  @override
  UserSummary get organizer;
  @override
  String get title;
  @override
  String? get description;
  @override
  MeetType get meetType;
  @override
  String? get category;
  @override
  String? get location; // Made nullable to handle null from backend
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  DateTime get scheduledAt;
  @override
  DateTime? get expiresAt;
  @override
  int? get durationMinutes;
  @override
  int get maxParticipants;
  @override
  int get acceptedCount;
  @override
  int get pendingMatchCount;
  @override
  MeetupStatus get status;
  @override
  ConfirmationStatus get confirmationStatus;
  @override
  double? get distanceKm;
  @override
  bool get userHasApplied;
  @override
  MatchStatus? get userMatchStatus;
  @override
  DateTime? get createdAt;

  /// Create a copy of MeetupModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeetupModelImplCopyWith<_$MeetupModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserSummary _$UserSummaryFromJson(Map<String, dynamic> json) {
  return _UserSummary.fromJson(json);
}

/// @nodoc
mixin _$UserSummary {
  String get id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String? get fullName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;

  /// Serializes this UserSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSummaryCopyWith<UserSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSummaryCopyWith<$Res> {
  factory $UserSummaryCopyWith(
          UserSummary value, $Res Function(UserSummary) then) =
      _$UserSummaryCopyWithImpl<$Res, UserSummary>;
  @useResult
  $Res call({String id, String username, String? fullName, String? avatarUrl});
}

/// @nodoc
class _$UserSummaryCopyWithImpl<$Res, $Val extends UserSummary>
    implements $UserSummaryCopyWith<$Res> {
  _$UserSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? fullName = freezed,
    Object? avatarUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserSummaryImplCopyWith<$Res>
    implements $UserSummaryCopyWith<$Res> {
  factory _$$UserSummaryImplCopyWith(
          _$UserSummaryImpl value, $Res Function(_$UserSummaryImpl) then) =
      __$$UserSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String username, String? fullName, String? avatarUrl});
}

/// @nodoc
class __$$UserSummaryImplCopyWithImpl<$Res>
    extends _$UserSummaryCopyWithImpl<$Res, _$UserSummaryImpl>
    implements _$$UserSummaryImplCopyWith<$Res> {
  __$$UserSummaryImplCopyWithImpl(
      _$UserSummaryImpl _value, $Res Function(_$UserSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? fullName = freezed,
    Object? avatarUrl = freezed,
  }) {
    return _then(_$UserSummaryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSummaryImpl extends _UserSummary {
  const _$UserSummaryImpl(
      {required this.id, required this.username, this.fullName, this.avatarUrl})
      : super._();

  factory _$UserSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSummaryImplFromJson(json);

  @override
  final String id;
  @override
  final String username;
  @override
  final String? fullName;
  @override
  final String? avatarUrl;

  @override
  String toString() {
    return 'UserSummary(id: $id, username: $username, fullName: $fullName, avatarUrl: $avatarUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, username, fullName, avatarUrl);

  /// Create a copy of UserSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSummaryImplCopyWith<_$UserSummaryImpl> get copyWith =>
      __$$UserSummaryImplCopyWithImpl<_$UserSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSummaryImplToJson(
      this,
    );
  }
}

abstract class _UserSummary extends UserSummary {
  const factory _UserSummary(
      {required final String id,
      required final String username,
      final String? fullName,
      final String? avatarUrl}) = _$UserSummaryImpl;
  const _UserSummary._() : super._();

  factory _UserSummary.fromJson(Map<String, dynamic> json) =
      _$UserSummaryImpl.fromJson;

  @override
  String get id;
  @override
  String get username;
  @override
  String? get fullName;
  @override
  String? get avatarUrl;

  /// Create a copy of UserSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSummaryImplCopyWith<_$UserSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MeetupMatchModel _$MeetupMatchModelFromJson(Map<String, dynamic> json) {
  return _MeetupMatchModel.fromJson(json);
}

/// @nodoc
mixin _$MeetupMatchModel {
  String get id => throw _privateConstructorUsedError;
  String get meetupId => throw _privateConstructorUsedError;
  UserSummary get user => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  MatchStatus get status => throw _privateConstructorUsedError;
  String? get conversationId => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get respondedAt => throw _privateConstructorUsedError;

  /// Serializes this MeetupMatchModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MeetupMatchModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeetupMatchModelCopyWith<MeetupMatchModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeetupMatchModelCopyWith<$Res> {
  factory $MeetupMatchModelCopyWith(
          MeetupMatchModel value, $Res Function(MeetupMatchModel) then) =
      _$MeetupMatchModelCopyWithImpl<$Res, MeetupMatchModel>;
  @useResult
  $Res call(
      {String id,
      String meetupId,
      UserSummary user,
      String? message,
      MatchStatus status,
      String? conversationId,
      DateTime? createdAt,
      DateTime? respondedAt});

  $UserSummaryCopyWith<$Res> get user;
}

/// @nodoc
class _$MeetupMatchModelCopyWithImpl<$Res, $Val extends MeetupMatchModel>
    implements $MeetupMatchModelCopyWith<$Res> {
  _$MeetupMatchModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeetupMatchModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? meetupId = null,
    Object? user = null,
    Object? message = freezed,
    Object? status = null,
    Object? conversationId = freezed,
    Object? createdAt = freezed,
    Object? respondedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      meetupId: null == meetupId
          ? _value.meetupId
          : meetupId // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserSummary,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MatchStatus,
      conversationId: freezed == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      respondedAt: freezed == respondedAt
          ? _value.respondedAt
          : respondedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of MeetupMatchModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserSummaryCopyWith<$Res> get user {
    return $UserSummaryCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MeetupMatchModelImplCopyWith<$Res>
    implements $MeetupMatchModelCopyWith<$Res> {
  factory _$$MeetupMatchModelImplCopyWith(_$MeetupMatchModelImpl value,
          $Res Function(_$MeetupMatchModelImpl) then) =
      __$$MeetupMatchModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String meetupId,
      UserSummary user,
      String? message,
      MatchStatus status,
      String? conversationId,
      DateTime? createdAt,
      DateTime? respondedAt});

  @override
  $UserSummaryCopyWith<$Res> get user;
}

/// @nodoc
class __$$MeetupMatchModelImplCopyWithImpl<$Res>
    extends _$MeetupMatchModelCopyWithImpl<$Res, _$MeetupMatchModelImpl>
    implements _$$MeetupMatchModelImplCopyWith<$Res> {
  __$$MeetupMatchModelImplCopyWithImpl(_$MeetupMatchModelImpl _value,
      $Res Function(_$MeetupMatchModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MeetupMatchModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? meetupId = null,
    Object? user = null,
    Object? message = freezed,
    Object? status = null,
    Object? conversationId = freezed,
    Object? createdAt = freezed,
    Object? respondedAt = freezed,
  }) {
    return _then(_$MeetupMatchModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      meetupId: null == meetupId
          ? _value.meetupId
          : meetupId // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserSummary,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MatchStatus,
      conversationId: freezed == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      respondedAt: freezed == respondedAt
          ? _value.respondedAt
          : respondedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MeetupMatchModelImpl implements _MeetupMatchModel {
  const _$MeetupMatchModelImpl(
      {required this.id,
      required this.meetupId,
      required this.user,
      this.message,
      required this.status,
      this.conversationId,
      this.createdAt,
      this.respondedAt});

  factory _$MeetupMatchModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeetupMatchModelImplFromJson(json);

  @override
  final String id;
  @override
  final String meetupId;
  @override
  final UserSummary user;
  @override
  final String? message;
  @override
  final MatchStatus status;
  @override
  final String? conversationId;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? respondedAt;

  @override
  String toString() {
    return 'MeetupMatchModel(id: $id, meetupId: $meetupId, user: $user, message: $message, status: $status, conversationId: $conversationId, createdAt: $createdAt, respondedAt: $respondedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeetupMatchModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.meetupId, meetupId) ||
                other.meetupId == meetupId) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.respondedAt, respondedAt) ||
                other.respondedAt == respondedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, meetupId, user, message,
      status, conversationId, createdAt, respondedAt);

  /// Create a copy of MeetupMatchModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeetupMatchModelImplCopyWith<_$MeetupMatchModelImpl> get copyWith =>
      __$$MeetupMatchModelImplCopyWithImpl<_$MeetupMatchModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MeetupMatchModelImplToJson(
      this,
    );
  }
}

abstract class _MeetupMatchModel implements MeetupMatchModel {
  const factory _MeetupMatchModel(
      {required final String id,
      required final String meetupId,
      required final UserSummary user,
      final String? message,
      required final MatchStatus status,
      final String? conversationId,
      final DateTime? createdAt,
      final DateTime? respondedAt}) = _$MeetupMatchModelImpl;

  factory _MeetupMatchModel.fromJson(Map<String, dynamic> json) =
      _$MeetupMatchModelImpl.fromJson;

  @override
  String get id;
  @override
  String get meetupId;
  @override
  UserSummary get user;
  @override
  String? get message;
  @override
  MatchStatus get status;
  @override
  String? get conversationId;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get respondedAt;

  /// Create a copy of MeetupMatchModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeetupMatchModelImplCopyWith<_$MeetupMatchModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
