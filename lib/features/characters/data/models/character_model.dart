import 'package:freezed_annotation/freezed_annotation.dart';

part 'character_model.freezed.dart';
part 'character_model.g.dart';

/// Modelo de personaje desde la API.
@freezed
class CharacterModel with _$CharacterModel {
  const factory CharacterModel({
    required int id,
    required String name,
    required String status,
    required String species,
    required String type,
    required String gender,
    required OriginModel origin,
    required LocationModel location,
    required String image,
    required List<String> episode,
    required String url,
    required String created,
  }) = _CharacterModel;

  factory CharacterModel.fromJson(Map<String, dynamic> json) =>
      _$CharacterModelFromJson(json);
}

/// Modelo de origen del personaje.
@freezed
class OriginModel with _$OriginModel {
  const factory OriginModel({
    required String name,
    required String url,
  }) = _OriginModel;

  factory OriginModel.fromJson(Map<String, dynamic> json) =>
      _$OriginModelFromJson(json);
}

/// Modelo de ubicación del personaje.
@freezed
class LocationModel with _$LocationModel {
  const factory LocationModel({
    required String name,
    required String url,
  }) = _LocationModel;

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);
}

/// Respuesta paginada de la API.
@freezed
class CharacterResponseModel with _$CharacterResponseModel {
  const factory CharacterResponseModel({
    required InfoModel info,
    required List<CharacterModel> results,
  }) = _CharacterResponseModel;

  factory CharacterResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CharacterResponseModelFromJson(json);
}

/// Información de paginación.
@freezed
class InfoModel with _$InfoModel {
  const factory InfoModel({
    required int count,
    required int pages,
    String? next,
    String? prev,
  }) = _InfoModel;

  factory InfoModel.fromJson(Map<String, dynamic> json) =>
      _$InfoModelFromJson(json);
}
