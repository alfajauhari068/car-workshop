import 'package:car_workshop/features/workshop/domain/entities/workshop_entity.dart';

class WorkshopModel extends WorkshopEntity {
  const WorkshopModel({
    required super.id,
    required super.name,
    required super.location,
    required super.ownerId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory WorkshopModel.fromJson(Map<String, dynamic> json) {
    return WorkshopModel(
      id: json['id'] as String?,
      name: (json['name'] as String?) ?? 'Unknown Workshop',
      location: (json['location'] as String?) ?? 'Unknown Location',
      ownerId: (json['owner_id'] as String?) ?? '',
      createdAt: (json['created_at'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updated_at'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'owner_id': ownerId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  WorkshopEntity toEntity() {
    return WorkshopEntity(
      id: id,
      name: name,
      location: location,
      ownerId: ownerId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
