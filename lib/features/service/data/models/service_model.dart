import 'package:car_workshop/features/service/domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.durationMinutes,
    required super.workshopId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      durationMinutes: json['duration_minutes'] as int,
      workshopId: json['workshop_id'] as String,
      createdAt: (json['created_at'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updated_at'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration_minutes': durationMinutes,
      'workshop_id': workshopId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  ServiceEntity toEntity() {
    return ServiceEntity(
      id: id,
      name: name,
      description: description,
      price: price,
      durationMinutes: durationMinutes,
      workshopId: workshopId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
