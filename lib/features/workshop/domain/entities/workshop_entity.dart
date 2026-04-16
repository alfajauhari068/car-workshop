import 'package:equatable/equatable.dart';
import '../../data/models/workshop_model.dart';

class WorkshopEntity extends Equatable {
  final String? id;
  final String name;
  final String location;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkshopEntity({
    this.id,
    required this.name,
    required this.location,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  WorkshopModel toModel() {
    return WorkshopModel(
      id: id,
      name: name,
      location: location,
      ownerId: ownerId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  WorkshopEntity copyWith({
    String? id,
    String? name,
    String? location,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkshopEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, location, ownerId, createdAt, updatedAt];
}
