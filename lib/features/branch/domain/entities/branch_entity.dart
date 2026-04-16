import 'package:equatable/equatable.dart';
import '../../data/models/branch_model.dart';

class BranchEntity extends Equatable {
  final String? id;
  final String name;
  final String address;
  final String phone;
  final String workshopId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BranchEntity({
    this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.workshopId,
    required this.createdAt,
    required this.updatedAt,
  });

  BranchModel toModel() {
    return BranchModel(
      id: id,
      name: name,
      address: address,
      phone: phone,
      workshopId: workshopId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  BranchEntity copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? workshopId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BranchEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      workshopId: workshopId ?? this.workshopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, address, phone, workshopId, createdAt, updatedAt];
}
