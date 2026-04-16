import 'package:equatable/equatable.dart';
import '../../data/models/service_model.dart';

class ServiceEntity extends Equatable {
  final String? id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final String workshopId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceEntity({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.workshopId,
    required this.createdAt,
    required this.updatedAt,
  });

  ServiceModel toModel() {
    return ServiceModel(
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

  ServiceEntity copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? durationMinutes,
    String? workshopId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      workshopId: workshopId ?? this.workshopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        durationMinutes,
        workshopId,
        createdAt,
        updatedAt,
      ];
}
