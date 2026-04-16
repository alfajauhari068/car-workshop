import 'package:car_workshop/core/errors/failure.dart';
import 'package:car_workshop/core/utils/logger_util.dart';

/// Basic MVP validator - only essential validations
/// Complex validations added in Phase 3+
class Validator {
  /// Validate workshop name and address
  static Failure? validateWorkshop({
    required String name,
    required String address,
  }) {
    if (name.trim().isEmpty) {
      Logger.warning('Validation: Workshop name is empty');
      return const InputFailure('Workshop name cannot be empty');
    }
    if (name.length < 3) {
      Logger.warning('Validation: Workshop name too short');
      return const InputFailure('Workshop name must be at least 3 characters');
    }
    if (address.trim().isEmpty) {
      Logger.warning('Validation: Workshop address is empty');
      return const InputFailure('Workshop address cannot be empty');
    }
    return null;
  }

  /// Validate branch name
  static Failure? validateBranch({
    required String name,
    required String address,
  }) {
    if (name.trim().isEmpty) {
      Logger.warning('Validation: Branch name is empty');
      return const InputFailure('Branch name cannot be empty');
    }
    if (name.length < 3) {
      Logger.warning('Validation: Branch name too short');
      return const InputFailure('Branch name must be at least 3 characters');
    }
    if (address.trim().isEmpty) {
      Logger.warning('Validation: Branch address is empty');
      return const InputFailure('Branch address cannot be empty');
    }
    return null;
  }

  /// Validate service data
  static Failure? validateService({
    required String name,
    required double price,
    required int duration,
  }) {
    if (name.trim().isEmpty) {
      Logger.warning('Validation: Service name is empty');
      return const InputFailure('Service name cannot be empty');
    }
    if (price <= 0) {
      Logger.warning('Validation: Service price invalid');
      return const InputFailure('Service price must be greater than 0');
    }
    if (duration <= 0) {
      Logger.warning('Validation: Service duration invalid');
      return const InputFailure('Service duration must be greater than 0');
    }
    return null;
  }

  /// Validate email format
  static Failure? validateEmail(String email) {
    if (email.trim().isEmpty) {
      Logger.warning('Validation: Email is empty');
      return const InputFailure('Email cannot be empty');
    }
    if (!email.contains('@') || !email.contains('.')) {
      Logger.warning('Validation: Email format invalid');
      return const InputFailure('Invalid email format');
    }
    return null;
  }

  /// Validate password
  static Failure? validatePassword(String password) {
    if (password.isEmpty) {
      Logger.warning('Validation: Password is empty');
      return const InputFailure('Password cannot be empty');
    }
    if (password.length < 6) {
      Logger.warning('Validation: Password too short');
      return const InputFailure('Password must be at least 6 characters');
    }
    return null;
  }

  /// Validate required field
  static Failure? validateRequired(String value, String fieldName) {
    if (value.trim().isEmpty) {
      Logger.warning('Validation: $fieldName is empty');
      return InputFailure('$fieldName cannot be empty');
    }
    return null;
  }
}
