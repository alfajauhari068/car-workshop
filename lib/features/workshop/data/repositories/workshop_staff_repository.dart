import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:car_workshop/core/errors/failure.dart';
import 'package:car_workshop/core/utils/logger_util.dart';
import '../../domain/entities/workshop_staff_entity.dart';
import '../models/workshop_staff_model.dart';

/// Repository for Workshop Staff (Pivot table between Users and Workshops)
/// Supports: 1 user can be in many workshops
class WorkshopStaffRepository {
  final FirebaseFirestore firestore;

  WorkshopStaffRepository(this.firestore);

  /// Add staff member to workshop (FLAT COLLECTION STRUCTURE)
  /// Document ID: '{userId}_{workshopId}' (composite key)
  /// Supports all roles: owner, manager, mechanic
  Future<Either<Failure, WorkshopStaffModel>> addStaffToWorkshop({
    required String workshopId,
    required String userId,
    required String name,
    required String email,
    required WorkshopRole role, // owner, manager, or mechanic
  }) async {
    try {
      Logger.info(
        'Adding staff to workshop: user=$userId, workshop=$workshopId, role=${role.value}',
      );

      // Validate inputs
      if (workshopId.isEmpty || userId.isEmpty || name.isEmpty || email.isEmpty) {
        return const Left(InputFailure('All fields are required'));
      }

      // Check if staff already exists
      final staffDocId = '${userId}_$workshopId';
      final staffDoc = await firestore
          .collection('workshop_staff')
          .doc(staffDocId)
          .get();

      if (staffDoc.exists) {
        Logger.warning('Staff already exists in workshop');
        return const Left(
          ServerFailure('User is already a staff member in this workshop'),
        );
      }

      // Check if workshop exists
      final workshopDoc = await firestore
          .collection('workshops')
          .doc(workshopId)
          .get();

      if (!workshopDoc.exists) {
        Logger.error('Workshop not found: $workshopId');
        return const Left(ServerFailure('Workshop does not exist'));
      }

      // Create staff document with composite key
      final now = DateTime.now();
      final staffModel = WorkshopStaffModel(
        workshopId: workshopId,
        userId: userId,
        name: name,
        email: email,
        role: role,
        joinedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      await firestore
          .collection('workshop_staff')
          .doc(staffDocId) // Use composite key as document ID
          .set(staffModel.toJson());

      Logger.repository(
        'CREATE',
        'workshop_staff',
        {
          'staff_id': staffDocId,
          'workshop_id': workshopId,
          'user_id': userId,
          'role': role.value,
        },
      );

      return Right(staffModel);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error adding staff: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to add staff'));
    } catch (e) {
      Logger.error('Error adding staff: $e');
      return Left(ServerFailure('Failed to add staff: $e'));
    }
  }

  /// Get all staff members for a workshop
  Future<Either<Failure, List<WorkshopStaffModel>>> getStaffForWorkshop(
    String workshopId,
  ) async {
    try {
      Logger.info('Fetching staff for workshop: $workshopId');

      final staffSnapshot = await firestore
          .collection('workshop_staff')
          .where('workshop_id', isEqualTo: workshopId)
          .orderBy('joined_at', descending: false)
          .get();

      final staff = staffSnapshot.docs
          .map((doc) => WorkshopStaffModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();

      Logger.repository(
        'READ_QUERY',
        'workshop_staff',
        {'workshop_id': workshopId, 'count': staff.length},
      );

      return Right(staff);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error fetching staff: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to fetch staff'));
    } catch (e) {
      Logger.error('Error fetching staff: $e');
      return Left(ServerFailure('Failed to fetch staff: $e'));
    }
  }

  /// Get all workshops for a user (one user in many workshops)
  Future<Either<Failure, List<WorkshopStaffModel>>> getWorkshopsForUser(
    String userId,
  ) async {
    try {
      Logger.info('Fetching workshops for user: $userId');

      final workshopsSnapshot = await firestore
          .collection('workshop_staff')
          .where('user_id', isEqualTo: userId)
          .orderBy('joined_at', descending: false)
          .get();

      final workshops = workshopsSnapshot.docs
          .map((doc) => WorkshopStaffModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();

      Logger.repository(
        'READ_QUERY',
        'workshop_staff',
        {'user_id': userId, 'count': workshops.length},
      );

      return Right(workshops);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error fetching user workshops: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to fetch workshops'));
    } catch (e) {
      Logger.error('Error fetching user workshops: $e');
      return Left(ServerFailure('Failed to fetch workshops: $e'));
    }
  }

  /// Get specific staff member
  Future<Either<Failure, WorkshopStaffModel?>> getStaffMember(
    String staffId,
  ) async {
    try {
      Logger.info('Fetching staff member: $staffId');

      final staffDoc = await firestore
          .collection('workshop_staff')
          .doc(staffId)
          .get();

      if (!staffDoc.exists) {
        Logger.warning('Staff member not found: $staffId');
        return const Right(null);
      }

      final staff = WorkshopStaffModel.fromJson({
        ...staffDoc.data()!,
        'id': staffDoc.id,
      });

      Logger.repository(
        'READ',
        'workshop_staff',
        {'staff_id': staffId},
      );

      return Right(staff);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error fetching staff: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to fetch staff'));
    } catch (e) {
      Logger.error('Error fetching staff: $e');
      return Left(ServerFailure('Failed to fetch staff: $e'));
    }
  }

  /// Update staff member role
  Future<Either<Failure, WorkshopStaffModel>> updateStaffRole({
    required String staffId,
    required String newRole,
  }) async {
    try {
      Logger.info('Updating staff role: $staffId -> $newRole');

      if (newRole != 'mechanic' && newRole != 'manager') {
        return const Left(InputFailure('Invalid role: must be mechanic or manager'));
      }

      final staffRef = firestore.collection('workshop_staff').doc(staffId);

      // Check if exists
      final staffDoc = await staffRef.get();
      if (!staffDoc.exists) {
        Logger.error('Staff not found: $staffId');
        return const Left(ServerFailure('Staff member does not exist'));
      }

      final updatedAt = DateTime.now();
      await staffRef.update({
        'role': newRole,
        'updated_at': Timestamp.fromDate(updatedAt),
      });

      final updatedStaff = WorkshopStaffModel.fromJson({
        ...staffDoc.data()!,
        'id': staffDoc.id,
        'role': newRole,
        'updated_at': updatedAt,
      });

      Logger.repository(
        'UPDATE',
        'workshop_staff',
        {'staff_id': staffId, 'new_role': newRole},
      );

      return Right(updatedStaff);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error updating staff role: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to update staff'));
    } catch (e) {
      Logger.error('Error updating staff role: $e');
      return Left(ServerFailure('Failed to update staff: $e'));
    }
  }

  /// Remove staff member from workshop
  Future<Either<Failure, void>> removeStaffFromWorkshop(String staffId) async {
    try {
      Logger.info('Removing staff member: $staffId');

      await firestore.collection('workshop_staff').doc(staffId).delete();

      Logger.repository(
        'DELETE',
        'workshop_staff',
        {'staff_id': staffId},
      );

      return const Right(null);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error removing staff: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to remove staff'));
    } catch (e) {
      Logger.error('Error removing staff: $e');
      return Left(ServerFailure('Failed to remove staff: $e'));
    }
  }

  /// Count staff members in workshop
  Future<Either<Failure, int>> countStaffInWorkshop(String workshopId) async {
    try {
      Logger.info('Counting staff in workshop: $workshopId');

      final snapshot = await firestore
          .collection('workshop_staff')
          .where('workshop_id', isEqualTo: workshopId)
          .count()
          .get();

      final count = snapshot.count ?? 0;

      Logger.repository(
        'COUNT',
        'workshop_staff',
        {'workshop_id': workshopId, 'count': count},
      );

      return Right(count);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error counting staff: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to count staff'));
    } catch (e) {
      Logger.error('Error counting staff: $e');
      return Left(ServerFailure('Failed to count staff: $e'));
    }
  }
}
