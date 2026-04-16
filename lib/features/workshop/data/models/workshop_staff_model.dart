import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_workshop/features/workshop/domain/entities/workshop_staff_entity.dart';

class WorkshopStaffModel extends WorkshopStaffEntity {
  const WorkshopStaffModel({
    required super.workshopId,
    required super.userId,
    required super.name,
    required super.email,
    required super.role,
    required super.joinedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory WorkshopStaffModel.fromJson(Map<String, dynamic> json) {
    return WorkshopStaffModel(
      workshopId: json['workshop_id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: WorkshopRoleExtension.fromString(json['role'] as String),
      joinedAt: (json['joined_at'] as dynamic)?.toDate() ?? DateTime.now(),
      createdAt: (json['created_at'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updated_at'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workshop_id': workshopId,
      'user_id': userId,
      'name': name,
      'email': email,
      'role': role.name, // ✅ Serialize enum as name (not value) for Firestore consistency
      'joined_at': Timestamp.fromDate(joinedAt),
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  WorkshopStaffEntity toEntity() {
    return WorkshopStaffEntity(
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
}
