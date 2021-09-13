// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/models_yclients/activity_model.dart';
import 'package:stretching/utils/enum_to_string.dart';
import 'package:stretching/utils/json_converters.dart';
import 'package:stretching/widgets/navigation/screens/activities_screen.dart';

/// The reason of wrong matched [ActivityModel].
enum SMAbonementNonMatchReason {
  /// Means abonement matches.
  none,

  /// Means abonement doesn't match activity's time.
  wrongTime,

  /// Means abonement doesn't match activity's studio.
  wrongStudio,

  /// Means abonement doesn't match activity's time and studio.
  wrongTimeAndStudio,
}

/// The extra data provided for [SMAbonementNonMatchReason].
extension SMAbonementNonMatchReasonData on SMAbonementNonMatchReason {
  /// The translation of this non match reason.
  String get translation =>
      '${TR.abonementNonMatchReason}.${enumToString(this)}'.tr();
}

/// The converter of the [SMAbonementModel].
const SMAbonementConverter smAbonementConverter = SMAbonementConverter._();

/// The converter of the [SMAbonementModel].
class SMAbonementConverter
    implements JsonConverter<SMAbonementModel, Map<String, Object?>> {
  const SMAbonementConverter._();

  @override
  SMAbonementModel fromJson(final Map<String, Object?> data) =>
      SMAbonementModel.fromMap(data);

  @override
  Map<String, Object?> toJson(final SMAbonementModel data) => data.toMap();
}

/// The abonement model entity from SMStretching API.
///
/// See: https://smstretching.ru/mobile/goods/{token}/get_all
@immutable
class SMAbonementModel implements Comparable<SMAbonementModel> {
  /// The abonement model entity from SMStretching API.
  ///
  /// See: https://smstretching.ru/mobile/goods/{token}/get_all
  const SMAbonementModel({
    required final this.id,
    required final this.count,
    required final this.service,
    required final this.time,
    required final this.ySrok,
    required final this.yHold,
    required final this.yId,
    required final this.cost,
  });

  /// The id of this abonement in the SMStretching API.
  final int id;

  /// The count of activities provided for this abonement.
  final int count;

  /// The id of studio that this abonement belongs too.
  final int? service;

  /// If this abonement is till 16:45 (true) or all day (false).
  final bool time;

  /// The active term of this abonement.
  final int ySrok;

  /// The possible count of days that this abonement can be freezed till.
  final int yHold;

  /// The id of this abonement in YClients API.
  final int yId;

  /// The cost that this abonement has been purchased with.
  final int cost;

  /// Returns true if this abonement matches the [activity].
  SMAbonementNonMatchReason matchActivity(final ActivityModel activity) {
    final matchesStudio = service == null || service == activity.companyId;
    final matchesTime = !time || ActivityTime.before.isWithin(activity.date);
    if (!matchesStudio && !matchesTime) {
      return SMAbonementNonMatchReason.wrongTimeAndStudio;
    } else if (matchesStudio && !matchesTime) {
      return SMAbonementNonMatchReason.wrongTime;
    } else if (matchesTime && !matchesStudio) {
      return SMAbonementNonMatchReason.wrongStudio;
    } else {
      return SMAbonementNonMatchReason.none;
    }
  }

  /// Return the copy of this model.
  SMAbonementModel copyWith({
    final int? id,
    final int? count,
    final int? service,
    final bool? time,
    final int? ySrok,
    final int? yHold,
    final int? yId,
    final int? cost,
  }) {
    return SMAbonementModel(
      id: id ?? this.id,
      count: count ?? this.count,
      service: service ?? this.service,
      time: time ?? this.time,
      ySrok: ySrok ?? this.ySrok,
      yHold: yHold ?? this.yHold,
      yId: yId ?? this.yId,
      cost: cost ?? this.cost,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      id.toString(): <String, Object?>{
        'count': count.toString(),
        'service': (service ?? 0).toString(),
        'time': boolToIntConverter.toJson(time).toString(),
        'y_srok': ySrok.toString(),
        'y_hold': yHold.toString(),
        'y_id': yId.toString(),
        'cost': cost.toString(),
      }
    };
  }

  /// Convert the map with string keys to this model.
  factory SMAbonementModel.fromMap(final Map<String, Object?> map) {
    final childMap = map.values.first! as Map<String, Object?>;
    final service = int.parse(childMap['service']! as String);
    return SMAbonementModel(
      id: int.parse(map.keys.first),
      count: int.parse(childMap['count']! as String),
      service: service == 0 ? null : service,
      time: boolToIntConverter.fromJson(int.parse(childMap['time']! as String)),
      ySrok: int.parse(childMap['y_srok']! as String),
      yHold: int.parse(childMap['y_hold']! as String),
      yId: int.parse(childMap['y_id']! as String),
      cost: int.parse(childMap['cost']! as String),
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory SMAbonementModel.fromJson(final String source) {
    return SMAbonementModel.fromMap(
      json.decode(source) as Map<String, Object?>,
    );
  }

  @override
  int compareTo(final SMAbonementModel other) => cost.compareTo(other.cost);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is SMAbonementModel &&
            other.id == id &&
            other.count == count &&
            other.service == service &&
            other.time == time &&
            other.ySrok == ySrok &&
            other.yHold == yHold &&
            other.yId == yId &&
            other.cost == cost;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        count.hashCode ^
        service.hashCode ^
        time.hashCode ^
        ySrok.hashCode ^
        yHold.hashCode ^
        yId.hashCode ^
        cost.hashCode;
  }

  @override
  String toString() {
    return 'SMAbonementModel(id: $id, count: $count, service: $service, '
        'time: $time, ySrok: $ySrok, yHold: $yHold, yId: $yId, cost: $cost)';
  }
}
