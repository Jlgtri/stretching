import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stretching/models/trainer_model.dart';
import 'package:stretching/utils/json_converters.dart';

// ignore_for_file: sort_constructors_first

/// The activity model of the yclients actitivities method.
///
/// See: https://yclientsru.docs.apiary.io/#reference/12/0/4
@immutable
class ActivityModel {
  /// The activity model of the yclients actitivities method.
  ///
  /// See: https://yclientsru.docs.apiary.io/#reference/12/0/4
  const ActivityModel({
    required final this.id,
    required final this.serviceId,
    required final this.companyId,
    required final this.staffId,
    required final this.date,
    required final this.length,
    required final this.capacity,
    required final this.recordsCount,
    required final this.color,
    required final this.instructions,
    required final this.streamLink,
    required final this.fontColor,
    required final this.notified,
    required final this.comment,
    required final this.prepaid,
    required final this.service,
    required final this.staff,
    required final this.resourceInstances,
    required final this.labels,
  });

  /// The id of this activity in the YClients API.
  final int id;

  /// The id of the service of this activity in the YClients API.
  final int serviceId;

  /// The id of the company of this activity in the YClients API.
  final int companyId;

  /// The id of the person responsible for this activity in the YClients API.
  final int staffId;

  /// The date and time of this activity.
  final DateTime date;

  /// The duration of this activity.
  final int length;

  /// The maximum count of people attending this activity.
  final int capacity;

  /// The current count of people that are going to go to this activity.
  final int recordsCount;
  final String color;
  final String instructions;
  final String streamLink;
  final String fontColor;
  final bool notified;
  final Object? comment;
  final PrepaidType prepaid;

  /// The service of this activity.
  final ActivityService service;

  /// The person that is going to run the activity.
  final StaffModel staff;

  /// The resources needed to run this activity.
  final Iterable<ResourceInstance> resourceInstances;

  final Iterable<Object?> labels;

  /// Return the copy of this model.
  ActivityModel copyWith({
    final int? id,
    final int? serviceId,
    final int? companyId,
    final int? staffId,
    final DateTime? date,
    final int? length,
    final int? capacity,
    final int? recordsCount,
    final String? color,
    final String? instructions,
    final String? streamLink,
    final String? fontColor,
    final bool? notified,
    final Object? comment,
    final PrepaidType? prepaid,
    final ActivityService? service,
    final StaffModel? staff,
    final Iterable<ResourceInstance>? resourceInstances,
    final Iterable<Object?>? labels,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      companyId: companyId ?? this.companyId,
      staffId: staffId ?? this.staffId,
      date: date ?? this.date,
      length: length ?? this.length,
      capacity: capacity ?? this.capacity,
      recordsCount: recordsCount ?? this.recordsCount,
      color: color ?? this.color,
      instructions: instructions ?? this.instructions,
      streamLink: streamLink ?? this.streamLink,
      fontColor: fontColor ?? this.fontColor,
      notified: notified ?? this.notified,
      comment: comment ?? this.comment,
      prepaid: prepaid ?? this.prepaid,
      service: service ?? this.service,
      staff: staff ?? this.staff,
      resourceInstances: resourceInstances ?? this.resourceInstances,
      labels: labels ?? this.labels,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'service_id': serviceId,
      'company_id': companyId,
      'staff_id': staffId,
      'date': date.toIso8601String(),
      'length': length,
      'capacity': capacity,
      'records_count': recordsCount,
      'color': color,
      'instructions': instructions,
      'stream_link': streamLink,
      'font_color': fontColor,
      'notified': notified,
      'comment': comment,
      'prepaid': prepaidConverter.toJson(prepaid),
      'service': service.toMap(),
      'staff': staff.toMap(),
      'resource_instances':
          resourceInstances.map((final resource) => resource.toMap()).toList(),
      'labels': labels.map((final label) => label).toList(),
    };
  }

  /// Convert the map with string keys to this model.
  factory ActivityModel.fromMap(final Map<String, Object?> map) {
    return ActivityModel(
      id: map['id']! as int,
      serviceId: map['service_id']! as int,
      companyId: map['company_id']! as int,
      staffId: map['staff_id']! as int,
      date: dateTimeConverter.fromJson(map['date']! as String),
      length: map['length']! as int,
      capacity: map['capacity']! as int,
      recordsCount: map['records_count']! as int,
      color: map['color']! as String,
      instructions: map['instructions']! as String,
      streamLink: map['stream_link']! as String,
      fontColor: map['font_color']! as String,
      notified: map['notified']! as bool,
      comment: map['comment'] as String?,
      prepaid: prepaidConverter.fromJson(map['prepaid']! as String),
      service: ActivityService.fromMap(map['service']! as Map<String, Object?>),
      staff: StaffModel.fromMap(map['staff']! as Map<String, Object?>),
      resourceInstances: (map['resource_instances']! as Iterable)
          .cast<Map<String, Object?>>()
          .map((final map) => ResourceInstance.fromMap(map)),
      labels: (map['labels']! as Iterable).cast<String>(),
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory ActivityModel.fromJson(final String source) =>
      ActivityModel.fromMap(json.decode(source));

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is ActivityModel &&
            other.id == id &&
            other.serviceId == serviceId &&
            other.companyId == companyId &&
            other.staffId == staffId &&
            other.date == date &&
            other.length == length &&
            other.capacity == capacity &&
            other.recordsCount == recordsCount &&
            other.color == color &&
            other.instructions == instructions &&
            other.streamLink == streamLink &&
            other.fontColor == fontColor &&
            other.notified == notified &&
            other.comment == comment &&
            other.prepaid == prepaid &&
            other.service == service &&
            other.staff == staff &&
            other.resourceInstances == resourceInstances &&
            other.labels == labels;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        serviceId.hashCode ^
        companyId.hashCode ^
        staffId.hashCode ^
        date.hashCode ^
        length.hashCode ^
        capacity.hashCode ^
        recordsCount.hashCode ^
        color.hashCode ^
        instructions.hashCode ^
        streamLink.hashCode ^
        fontColor.hashCode ^
        notified.hashCode ^
        comment.hashCode ^
        prepaid.hashCode ^
        service.hashCode ^
        staff.hashCode ^
        resourceInstances.hashCode ^
        labels.hashCode;
  }

  @override
  String toString() {
    return 'ActivityModel(id: $id, serviceId: $serviceId, '
        'companyId: $companyId, staffId: $staffId, date: $date, '
        'length: $length, capacity: $capacity, recordsCount: $recordsCount, '
        'color: $color, instructions: $instructions, streamLink: $streamLink, '
        'fontColor: $fontColor, notified: $notified, comment: $comment, '
        'prepaid: $prepaid, service: $service, staff: $staff, '
        'resourceInstances: $resourceInstances, labels: $labels)';
  }
}

/// The resources provided for [ActivityModel].
@immutable
class ResourceInstance {
  /// The resources provided for [ActivityModel].
  const ResourceInstance({
    required final this.id,
    required final this.title,
    required final this.resourceId,
  });

  /// The id of this resource instance in the YClients API.
  final int id;

  /// The title of this resource.
  final String title;

  /// The id of the resource of this instance in the YClients API.
  final int resourceId;

  /// Return the copy of this model.
  ResourceInstance copyWith({
    final int? id,
    final String? title,
    final int? resourceId,
  }) {
    return ResourceInstance(
      id: id ?? this.id,
      title: title ?? this.title,
      resourceId: resourceId ?? this.resourceId,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'resource_id': resourceId,
    };
  }

  /// Convert the map with string keys to this model.
  factory ResourceInstance.fromMap(final Map<String, Object?> map) {
    return ResourceInstance(
      id: map['id']! as int,
      title: map['title']! as String,
      resourceId: map['resource_id']! as int,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory ResourceInstance.fromJson(final String source) =>
      ResourceInstance.fromMap(json.decode(source));

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is ResourceInstance &&
            other.id == id &&
            other.title == title &&
            other.resourceId == resourceId;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ resourceId.hashCode;

  @override
  String toString() {
    return 'ResourceInstance(id: $id, title: $title, resourceId: $resourceId)';
  }
}

/// The service provided for [ActivityModel].
@immutable
class ActivityService {
  /// The service provided for [ActivityModel].
  const ActivityService({
    required final this.id,
    required final this.categoryId,
    required final this.title,
    required final this.priceMin,
    required final this.priceMax,
    required final this.comment,
    required final this.imageUrl,
    required final this.salonServiceId,
    required final this.prepaid,
    required final this.category,
  });

  /// The id of this service.
  final int id;

  /// The id of the catogory of this service.
  final int categoryId;

  /// The title of this service.
  final String title;

  /// The minimum price of this service.
  final int priceMin;

  /// The maximum price of this service.
  final int priceMax;

  /// The information provided for this service.
  final String comment;

  /// The link to the image of this service.
  final String imageUrl;

  /// The id of the salon service in the YClients API.
  final int salonServiceId;

  final PrepaidType prepaid;

  /// The category of this service.
  final ActivityServiceCategory category;

  /// Return the copy of this model.
  ActivityService copyWith({
    final int? id,
    final int? categoryId,
    final String? title,
    final int? priceMin,
    final int? priceMax,
    final String? comment,
    final String? imageUrl,
    final int? salonServiceId,
    final PrepaidType? prepaid,
    final ActivityServiceCategory? category,
  }) {
    return ActivityService(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      comment: comment ?? this.comment,
      imageUrl: imageUrl ?? this.imageUrl,
      salonServiceId: salonServiceId ?? this.salonServiceId,
      prepaid: prepaid ?? this.prepaid,
      category: category ?? this.category,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'category_id': categoryId,
      'title': title,
      'price_min': priceMin,
      'price_max': priceMax,
      'comment': comment,
      'image_url': imageUrl,
      'salon_service_id': salonServiceId,
      'prepaid': prepaidConverter.toJson(prepaid),
      'category': category.toMap(),
    };
  }

  /// Convert the map with string keys to this model.
  factory ActivityService.fromMap(final Map<String, Object?> map) {
    return ActivityService(
      id: map['id']! as int,
      categoryId: map['category_id']! as int,
      title: map['title']! as String,
      priceMin: map['price_min']! as int,
      priceMax: map['price_max']! as int,
      comment: map['comment']! as String,
      imageUrl: map['image_url']! as String,
      salonServiceId: map['salon_service_id']! as int,
      prepaid: prepaidConverter.fromJson(map['prepaid']! as String),
      category: ActivityServiceCategory.fromMap(
        map['category']! as Map<String, Object?>,
      ),
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory ActivityService.fromJson(final String source) =>
      ActivityService.fromMap(json.decode(source));

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is ActivityService &&
            other.id == id &&
            other.categoryId == categoryId &&
            other.title == title &&
            other.priceMin == priceMin &&
            other.priceMax == priceMax &&
            other.comment == comment &&
            other.imageUrl == imageUrl &&
            other.salonServiceId == salonServiceId &&
            other.prepaid == prepaid &&
            other.category == category;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        categoryId.hashCode ^
        title.hashCode ^
        priceMin.hashCode ^
        priceMax.hashCode ^
        comment.hashCode ^
        imageUrl.hashCode ^
        salonServiceId.hashCode ^
        prepaid.hashCode ^
        category.hashCode;
  }

  @override
  String toString() {
    return 'ActivityService(id: $id, categoryId: $categoryId, title: $title, '
        'priceMin: $priceMin, priceMax: $priceMax, comment: $comment, '
        'imageUrl: $imageUrl, salonServiceId: $salonServiceId, '
        'prepaid: $prepaid, category: $category)';
  }
}

/// The category of the [ActivityService].
@immutable
class ActivityServiceCategory {
  /// The category of the [ActivityService].
  const ActivityServiceCategory({
    required final this.id,
    required final this.categoryId,
    required final this.title,
  });

  /// The id of this category in the YClients API.
  final int id;

  /// The id of this category in the [ActivityService].
  final int categoryId;

  /// The title of this category.
  final String title;

  /// Return the copy of this model.
  ActivityServiceCategory copyWith({
    final int? id,
    final int? categoryId,
    final String? title,
  }) {
    return ActivityServiceCategory(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'category_id': categoryId,
      'title': title
    };
  }

  /// Convert the map with string keys to this model.
  factory ActivityServiceCategory.fromMap(final Map<String, Object?> json) {
    return ActivityServiceCategory(
      id: json['id']! as int,
      categoryId: json['category_id']! as int,
      title: json['title']! as String,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory ActivityServiceCategory.fromJson(final String source) =>
      ActivityServiceCategory.fromMap(json.decode(source));

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is ActivityServiceCategory &&
            other.id == id &&
            other.categoryId == categoryId &&
            other.title == title;
  }

  @override
  int get hashCode => id.hashCode ^ categoryId.hashCode ^ title.hashCode;

  @override
  String toString() {
    return 'ActivityServiceCategory(id: $id, categoryId: $categoryId, '
        'title: $title)';
  }
}

/// The model of a person responsible for [ActivityModel].
@immutable
class StaffModel {
  /// The model of a person responsible for [ActivityModel].
  const StaffModel({
    required final this.id,
    required final this.apiId,
    required final this.name,
    required final this.companyId,
    required final this.specialization,
    required final this.rating,
    required final this.showRating,
    required final this.avatar,
    required final this.avatarBig,
    required final this.commentsCount,
    required final this.votesCount,
    required final this.averageScore,
    required final this.prepaid,
    required final this.position,
  });

  /// The id of this staff member in YClients API.
  final int id;
  final Object? apiId;

  /// The name of this staff member in YClients API.
  final String name;

  /// The id of the company this staff member is in.
  final int companyId;

  /// The specialization of this staff member.
  final String specialization;

  /// The rating of this staff member.
  final int rating;

  /// If the rating of this staff member should be shown.
  final bool showRating;

  /// The link to the avatar of this staff member.
  final String avatar;

  /// The link to the bigger avatar of this staff member.
  final String avatarBig;

  /// The count of comments of this staff member.
  final int commentsCount;

  /// The count of votes of this staff member.
  final int votesCount;

  /// The average score of this staff member.
  final int averageScore;

  final PrepaidType prepaid;

  /// The position of this staff member.
  final StaffPosition position;

  /// Return the copy of this model.
  StaffModel copyWith({
    final int? id,
    final Object? apiId,
    final String? name,
    final int? companyId,
    final String? specialization,
    final int? rating,
    final bool? showRating,
    final String? avatar,
    final String? avatarBig,
    final int? commentsCount,
    final int? votesCount,
    final int? averageScore,
    final PrepaidType? prepaid,
    final StaffPosition? position,
  }) {
    return StaffModel(
      id: id ?? this.id,
      apiId: apiId ?? this.apiId,
      name: name ?? this.name,
      companyId: companyId ?? this.companyId,
      specialization: specialization ?? this.specialization,
      rating: rating ?? this.rating,
      showRating: showRating ?? this.showRating,
      avatar: avatar ?? this.avatar,
      avatarBig: avatarBig ?? this.avatarBig,
      commentsCount: commentsCount ?? this.commentsCount,
      votesCount: votesCount ?? this.votesCount,
      averageScore: averageScore ?? this.averageScore,
      prepaid: prepaid ?? this.prepaid,
      position: position ?? this.position,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'api_id': apiId,
      'name': name,
      'company_id': companyId,
      'specialization': specialization,
      'rating': rating,
      'show_rating': showRating,
      'avatar': avatar,
      'avatar_big': avatarBig,
      'comments_count': commentsCount,
      'votes_count': votesCount,
      'average_score': averageScore,
      'prepaid': prepaidConverter.toJson(prepaid),
      'position': position.toMap(),
    };
  }

  /// Convert the map with string keys to this model.
  factory StaffModel.fromMap(final Map<String, Object?> map) {
    return StaffModel(
      id: map['id']! as int,
      apiId: map['api_id'],
      name: map['name']! as String,
      companyId: map['company_id']! as int,
      specialization: map['specialization']! as String,
      rating: map['rating']! as int,
      showRating: boolToIntConverter.fromJson(map['show_rating']! as int),
      avatar: map['avatar']! as String,
      avatarBig: map['avatar_big']! as String,
      commentsCount: map['comments_count']! as int,
      votesCount: map['votes_count']! as int,
      averageScore: map['average_score']! as int,
      prepaid: prepaidConverter.fromJson(map['prepaid']! as String),
      position: StaffPosition.fromMap(map['position']! as Map<String, Object?>),
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory StaffModel.fromJson(final String source) =>
      StaffModel.fromMap(json.decode(source));

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is StaffModel &&
            other.id == id &&
            other.apiId == apiId &&
            other.name == name &&
            other.companyId == companyId &&
            other.specialization == specialization &&
            other.rating == rating &&
            other.showRating == showRating &&
            other.avatar == avatar &&
            other.avatarBig == avatarBig &&
            other.commentsCount == commentsCount &&
            other.votesCount == votesCount &&
            other.averageScore == averageScore &&
            other.prepaid == prepaid &&
            other.position == position;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        apiId.hashCode ^
        name.hashCode ^
        companyId.hashCode ^
        specialization.hashCode ^
        rating.hashCode ^
        showRating.hashCode ^
        avatar.hashCode ^
        avatarBig.hashCode ^
        commentsCount.hashCode ^
        votesCount.hashCode ^
        averageScore.hashCode ^
        prepaid.hashCode ^
        position.hashCode;
  }

  @override
  String toString() {
    return 'StaffModel(id: $id, apiId: $apiId, name: $name, '
        'companyId: $companyId, specialization: $specialization, '
        'rating: $rating, showRating: $showRating, avatar: $avatar, '
        'avatarBig: $avatarBig, commentsCount: $commentsCount, '
        'votesCount: $votesCount, averageScore: $averageScore, '
        'prepaid: $prepaid, position: $position)';
  }
}

/// The position for the [StaffModel].
@immutable
class StaffPosition {
  /// The position for the [StaffModel].
  const StaffPosition({required final this.id, required final this.title});

  /// The id of this position.
  final int id;

  /// The title of this position.
  final String title;

  /// Return the copy of this model.
  StaffPosition copyWith({final int? id, final String? title}) {
    return StaffPosition(id: id ?? this.id, title: title ?? this.title);
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{'id': id, 'title': title};
  }

  /// Convert the map with string keys to this model.
  factory StaffPosition.fromMap(final Map<String, Object?> map) {
    return StaffPosition(id: map['id']! as int, title: map['title']! as String);
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory StaffPosition.fromJson(final String source) =>
      StaffPosition.fromMap(json.decode(source));

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is StaffPosition && other.id == id && other.title == title;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode;

  @override
  String toString() => 'StaffPosition(id: $id, title: $title)';
}
