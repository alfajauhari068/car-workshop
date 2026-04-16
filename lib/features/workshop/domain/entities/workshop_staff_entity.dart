import 'package:equatable/equatable.dart';
import '../../data/models/workshop_staff_model.dart';

/// Workshop Role Enum - MANDATORY for all staff including owner
enum WorkshopRole {
  owner,
  manager,
  mechanic,
}

extension WorkshopRoleExtension on WorkshopRole {
  String get value => toString().split('.').last;
  
  static WorkshopRole fromString(String value) {
    return WorkshopRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => WorkshopRole.mechanic,
    );
  }
}

class WorkshopStaffEntity extends Equatable {
  final String workshopId;
  final String userId;
  final String name;
  final String email;
  final WorkshopRole role; // owner, manager, or mechanic
  final DateTime joinedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Document ID in Firestore: '{userId}_{workshopId}'
  /// This is a composite key for flat collection structure
  String get id => '${userId}_$workshopId';
  
  const WorkshopStaffEntity({
    required this.workshopId,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.joinedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  WorkshopStaffModel toModel() {
    return WorkshopStaffModel(
      workshopId: workshopId,
      userId: userId,
      name: name,
      email: email,
      role: role,
      joinedAt: joinedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  WorkshopStaffEntity copyWith({
    String? workshopId,
    String? userId,
    String? name,
    String? email,
    WorkshopRole? role,
    DateTime? joinedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkshopStaffEntity(
      workshopId: workshopId ?? this.workshopId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workshopId,
        userId,
        name,
        email,
        role,
        joinedAt,
        createdAt,
        updatedAt,
      ];
}
