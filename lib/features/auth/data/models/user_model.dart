import 'package:car_workshop/features/auth/domain/entities/user_entity.dart';

import '../../../../core/enums/user_role.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    super.profileComplete = false,
    super.skills,
    super.yearsOfExperience,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.values
          .firstWhere((e) => e.toString() == 'UserRole.${json['role']}'),
      profileComplete: json['profileComplete'] as bool? ?? false,
      skills: (json['skills'] as List<dynamic>?)?.cast<String>(),
      yearsOfExperience: json['yearsOfExperience'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toString().split('.').last, // Convert enum to string
      'profileComplete': profileComplete,
      'skills': skills,
      'yearsOfExperience': yearsOfExperience,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      role: role,
    );
  }
}
