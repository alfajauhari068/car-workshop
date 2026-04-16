import 'package:equatable/equatable.dart';
import '../../../../core/enums/user_role.dart';
import '../../data/models/user_model.dart';

class UserEntity extends Equatable {
  final String? id;
  final String email;
  final String name;
  final UserRole role;
  final bool profileComplete;
  final List<String>? skills;
  final String? yearsOfExperience;

  const UserEntity({
    this.id,
    required this.email,
    required this.name,
    required this.role,
    this.profileComplete = false,
    this.skills,
    this.yearsOfExperience,
  });

  UserModel toModel() {
    return UserModel(
      id: id,
      email: email,
      name: name,
      role: role,
      profileComplete: profileComplete,
      skills: skills,
      yearsOfExperience: yearsOfExperience,
    );
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    bool? profileComplete,
    List<String>? skills,
    String? yearsOfExperience,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profileComplete: profileComplete ?? this.profileComplete,
      skills: skills ?? this.skills,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
    );
  }

  @override
  List<Object?> get props => [id, email, name, role, profileComplete, skills, yearsOfExperience];
}
