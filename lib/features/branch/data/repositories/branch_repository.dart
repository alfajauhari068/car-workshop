import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:car_workshop/core/errors/failure.dart';
import 'package:car_workshop/core/utils/logger_util.dart';
import '../models/branch_model.dart';

class BranchRepository {
  final FirebaseFirestore firestore;

  BranchRepository(this.firestore);

  /// Create new branch for a workshop
  Future<Either<Failure, BranchModel>> createBranch({
    required String workshopId,
    required String name,
    required String address,
    required String phone,
  }) async {
    try {
      Logger.info('Creating branch: $name for workshop: $workshopId');

      // Validate inputs
      if (name.isEmpty || address.isEmpty || phone.isEmpty) {
        return const Left(InputFailure('All fields are required'));
      }

      // Create branch under workshops/{workshopId}/branches/{branchId}
      final branchRef = firestore
          .collection('workshops')
          .doc(workshopId)
          .collection('branches')
          .doc();

      final now = DateTime.now();
      final branchModel = BranchModel(
        id: branchRef.id,
        name: name,
        address: address,
        phone: phone,
        workshopId: workshopId,
        createdAt: now,
        updatedAt: now,
      );

      await branchRef.set(branchModel.toJson());

      Logger.repository(
        'CREATE',
        'branches',
        {
          'branch_id': branchRef.id,
          'workshop_id': workshopId,
          'name': name,
        },
      );

      return Right(branchModel);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error creating branch: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to create branch'));
    } catch (e) {
      Logger.error('Error creating branch: $e');
      return Left(ServerFailure('Failed to create branch: $e'));
    }
  }

  /// Get all branches for a workshop
  Future<Either<Failure, List<BranchModel>>> getBranchesForWorkshop(
    String workshopId,
  ) async {
    try {
      Logger.info('Fetching branches for workshop: $workshopId');

      final branchSnapshot = await firestore
          .collection('workshops')
          .doc(workshopId)
          .collection('branches')
          .orderBy('created_at', descending: true)
          .get();

      final branches = branchSnapshot.docs
          .map((doc) => BranchModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();

      Logger.repository(
        'READ_QUERY',
        'branches',
        {'workshop_id': workshopId, 'count': branches.length},
      );

      return Right(branches);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error fetching branches: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to fetch branches'));
    } catch (e) {
      Logger.error('Error fetching branches: $e');
      return Left(ServerFailure('Failed to fetch branches: $e'));
    }
  }

  /// Get single branch by ID
  Future<Either<Failure, BranchModel>> getBranch({
    required String workshopId,
    required String branchId,
  }) async {
    try {
      Logger.info('Fetching branch: $branchId from workshop: $workshopId');

      final doc = await firestore
          .collection('workshops')
          .doc(workshopId)
          .collection('branches')
          .doc(branchId)
          .get();

      if (!doc.exists) {
        return const Left(NotFoundFailure('Branch not found'));
      }

      return Right(BranchModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      }));
    } on FirebaseException catch (e) {
      Logger.error('Firebase error fetching branch: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to fetch branch'));
    } catch (e) {
      Logger.error('Error fetching branch: $e');
      return Left(ServerFailure('Failed to fetch branch: $e'));
    }
  }

  /// Update branch
  Future<Either<Failure, void>> updateBranch({
    required String workshopId,
    required String branchId,
    required String name,
    required String address,
    required String phone,
  }) async {
    try {
      Logger.info('Updating branch: $branchId in workshop: $workshopId');

      if (name.isEmpty || address.isEmpty || phone.isEmpty) {
        return const Left(InputFailure('All fields are required'));
      }

      await firestore
          .collection('workshops')
          .doc(workshopId)
          .collection('branches')
          .doc(branchId)
          .update({
        'name': name,
        'address': address,
        'phone': phone,
        'updated_at': DateTime.now(),
      });

      Logger.repository(
        'UPDATE',
        'branches',
        {'branch_id': branchId, 'workshop_id': workshopId},
      );

      return const Right(null);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error updating branch: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to update branch'));
    } catch (e) {
      Logger.error('Error updating branch: $e');
      return Left(ServerFailure('Failed to update branch: $e'));
    }
  }

  /// Delete branch
  Future<Either<Failure, void>> deleteBranch({
    required String workshopId,
    required String branchId,
  }) async {
    try {
      Logger.info('Deleting branch: $branchId from workshop: $workshopId');

      await firestore
          .collection('workshops')
          .doc(workshopId)
          .collection('branches')
          .doc(branchId)
          .delete();

      Logger.repository(
        'DELETE',
        'branches',
        {'branch_id': branchId, 'workshop_id': workshopId},
      );

      return const Right(null);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error deleting branch: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to delete branch'));
    } catch (e) {
      Logger.error('Error deleting branch: $e');
      return Left(ServerFailure('Failed to delete branch: $e'));
    }
  }

  /// Count branches in workshop
  Future<Either<Failure, int>> getBranchCount(String workshopId) async {
    try {
      final snapshot = await firestore
          .collection('workshops')
          .doc(workshopId)
          .collection('branches')
          .count()
          .get();

      return Right(snapshot.count ?? 0);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error counting branches: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to count branches'));
    } catch (e) {
      Logger.error('Error counting branches: $e');
      return Left(ServerFailure('Failed to count branches: $e'));
    }
  }
}
