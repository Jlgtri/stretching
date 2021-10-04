// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stretching/models/smstretching/sm_studio_model.dart';
import 'package:stretching/utils/json_converters.dart';

/// The converter of the [SMStudioOptionsModel].
const SMStudioOptionsConverter smStudioOptionsConverter =
    SMStudioOptionsConverter._();

/// The converter of the [SMStudioOptionsModel].
class SMStudioOptionsConverter
    implements JsonConverter<SMStudioOptionsModel, Map<String, Object?>> {
  const SMStudioOptionsConverter._();

  @override
  SMStudioOptionsModel fromJson(final Map<String, Object?> data) =>
      SMStudioOptionsModel.fromMap(data);

  @override
  Map<String, Object?> toJson(final SMStudioOptionsModel data) => data.toMap();
}

/// The model of additional options for [SMStudioModel].
///
/// See: https://smstretching.ru/mobile/options/{token}/get_all
@immutable
class SMStudioOptionsModel {
  /// The model of additional options for [SMStudioModel].
  ///
  /// See: https://smstretching.ru/mobile/options/{token}/get_all
  const SMStudioOptionsModel({
    required final this.studioId,
    required final this.skladId,
    required final this.kassaId,
    required final this.kassirSiteId,
    required final this.kassirMobileId,
    required final this.categoryAbId,
    required final this.key,
    required final this.pass,
    required final this.keySite,
    required final this.passSite,
  });

  /// The id of the studio that this options belong to.
  final int studioId;

  /// The id of the storage of this studio in the YClients API.
  final int skladId;

  /// The id of the cashbox of this studio in the YClients API.
  final int kassaId;

  /// The id of the cashier for site sales of this studio in the YClients API.
  final int kassirSiteId;

  /// The id of the cashier for mobile sales of this studio in the YClients API.
  final int kassirMobileId;

  /// The product id for the abonement of this studio in the YClients API.
  final int categoryAbId;

  /// The Tinkoff terminal key for processing the payment on mobile for this
  /// studio.
  final String key;

  /// The Tinkoff terminal password for processing the payment on mobile for
  /// this studio.
  final String pass;

  /// The Tinkoff terminal key for processing the payment on site for this
  /// studio.
  final String keySite;

  /// The Tinkoff terminal password for processing the payment on site for this
  /// studio.
  final String passSite;

  /// Return the copy of this model.
  SMStudioOptionsModel copyWith({
    final int? studioId,
    final int? skladId,
    final int? kassaId,
    final int? kassirSiteId,
    final int? kassirMobileId,
    final int? categoryAbId,
    final String? key,
    final String? pass,
    final String? keySite,
    final String? passSite,
  }) =>
      SMStudioOptionsModel(
        studioId: studioId ?? this.studioId,
        skladId: skladId ?? this.skladId,
        kassaId: kassaId ?? this.kassaId,
        kassirSiteId: kassirSiteId ?? this.kassirSiteId,
        kassirMobileId: kassirMobileId ?? this.kassirMobileId,
        categoryAbId: categoryAbId ?? this.categoryAbId,
        key: key ?? this.key,
        pass: pass ?? this.pass,
        keySite: keySite ?? this.keySite,
        passSite: passSite ?? this.passSite,
      );

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() => <String, Object?>{
        studioId.toString(): <String, Object?>{
          'sklad_id': skladId.toString(),
          'kassa_id': kassaId.toString(),
          'kassir_site_id': kassirSiteId.toString(),
          'kassir_mobile_id': kassirMobileId.toString(),
          'category_ab_id': categoryAbId.toString(),
          'key': key,
          'pass': pass,
          'key_site': keySite,
          'pass_site': passSite,
        }
      };

  /// Convert the map with string keys to this model.
  factory SMStudioOptionsModel.fromMap(final Map<String, Object?> map) {
    final childMap = map.values.first! as Map<String, Object?>;
    return SMStudioOptionsModel(
      studioId: int.parse(map.keys.first),
      skladId: int.parse(childMap['sklad_id']! as String),
      kassaId: int.parse(childMap['kassa_id']! as String),
      kassirSiteId: int.parse(childMap['kassir_site_id']! as String),
      kassirMobileId: int.parse(childMap['kassir_mobile_id']! as String),
      categoryAbId: int.parse(childMap['category_ab_id']! as String),
      key: childMap['key']! as String,
      pass: childMap['pass']! as String,
      keySite: childMap['key_site']! as String,
      passSite: childMap['pass_site']! as String,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory SMStudioOptionsModel.fromJson(final String source) =>
      SMStudioOptionsModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is SMStudioOptionsModel &&
          other.studioId == studioId &&
          other.skladId == skladId &&
          other.kassaId == kassaId &&
          other.kassirSiteId == kassirSiteId &&
          other.kassirMobileId == kassirMobileId &&
          other.categoryAbId == categoryAbId &&
          other.key == key &&
          other.pass == pass &&
          other.keySite == keySite &&
          other.passSite == passSite;

  @override
  int get hashCode =>
      studioId.hashCode ^
      skladId.hashCode ^
      kassaId.hashCode ^
      kassirSiteId.hashCode ^
      kassirMobileId.hashCode ^
      categoryAbId.hashCode ^
      key.hashCode ^
      pass.hashCode ^
      keySite.hashCode ^
      passSite.hashCode;

  @override
  String toString() =>
      'SMStudioOptionsModel(studioId: $studioId, skladId: $skladId, '
      'kassaId: $kassaId, kassirSiteId: $kassirSiteId, '
      'kassirMobileId: $kassirMobileId, categoryAbId: $categoryAbId, '
      'key: $key, pass: $pass, keySite: $keySite, passSite: $passSite)';
}
