import 'package:car_workshop/features/branch/domain/entities/branch_entity.dart';

class BranchModel extends BranchEntity {
  const BranchModel({
    required super.id,
    required super.name,
    required super.address,
    required super.phone,
    required super.workshopId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      workshopId: json['workshop_id'] as String,
      createdAt: (json['created_at'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updated_at'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'workshop_id': workshopId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  BranchEntity toEntity() {
    return BranchEntity(
      id: id,
      name: name,
      address: address,
      phone: phone,
      workshopId: workshopId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
