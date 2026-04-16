import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:car_workshop/core/errors/failure.dart';
import 'package:car_workshop/core/utils/logger_util.dart';
import '../../domain/entities/workshop_staff_entity.dart';
import '../models/workshop_model.dart';

class WorkshopRepository {
  final FirebaseFirestore firestore;

  WorkshopRepository(this.firestore);

  /// Create workshop with owner added to flat workshop_staff collection (TRANSACTION)
  /// WAJIB: Owner entry is mandatory in workshop_staff pivot table
  /// Document ID: '{ownerId}_{workshopId}' (composite key)
  Future<Either<Failure, WorkshopModel>> createWorkshop({
    required String name,
    required String location,
    required String ownerId,
    required String ownerName,
    required String ownerEmail,
  }) async {
    try {
      Logger.info('Creating workshop: $name at $location');

      late WorkshopModel createdWorkshop;

      // Use transaction to ensure atomicity
      await firestore.runTransaction<void>((transaction) async {
        // STEP 1: Create workshop document
        final workshopRef = firestore.collection('workshops').doc();
        final now = DateTime.now();
        final workshopModel = WorkshopModel(
          id: workshopRef.id,
          name: name,
          location: location,
          ownerId: ownerId,
          createdAt: now,
          updatedAt: now,
        );

        transaction.set(workshopRef, workshopModel.toJson());
        createdWorkshop = workshopModel;

        // STEP 2: Add owner to FLAT workshop_staff collection (MANDATORY)
        // Document ID: '{ownerId}_{workshopId}' (composite key)
        final staffDocId = '${ownerId}_${workshopRef.id}';
        final staffRef = firestore.collection('workshop_staff').doc(staffDocId);

        transaction.set(staffRef, {
          'user_id': ownerId,
          'workshop_id': workshopRef.id,
          'email': ownerEmail,
          'name': ownerName,
          'role': WorkshopRole.owner.value, // 'owner'
          'joined_at': now,
          'created_at': now,
          'updated_at': now,
        });

        Logger.repository(
          'CREATE',
          'workshops',
          {
            'workshop_id': workshopRef.id,
            'owner_id': ownerId,
            'staff_doc_id': staffDocId,
          },
        );
      });

      return Right(createdWorkshop);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error creating workshop: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to create workshop'));
    } catch (e) {
      Logger.error('Error creating workshop: $e');
      return Left(ServerFailure('Failed to create workshop: $e'));
    }
  }

  /// Get all workshops owned by or where user is staff (FLAT workshop_staff collection)
  /// Uses composite key: '{userId}_{workshopId}' to check user access
  /// Owner can always see their workshops, staff can see if they have access
  Future<Either<Failure, List<WorkshopModel>>> getWorkshopsForUser(
    String userId,
  ) async {
    try {
      Logger.info('Fetching workshops for user: $userId');

      if (userId.isEmpty) {
        Logger.error('User ID is empty');
        return const Left(ServerFailure('User ID is empty'));
      }

      // Get workshops where user is owner
      final ownerSnapshot = await firestore
          .collection('workshops')
          .where('owner_id', isEqualTo: userId)
          .get();

      final workshops = <WorkshopModel>[];

      Logger.info('Found ${ownerSnapshot.docs.length} workshops as owner');

      for (var doc in ownerSnapshot.docs) {
        final workshopId = doc.id;
        final data = doc.data();
        
        Logger.info('Processing workshop: $workshopId, data keys: ${data.keys}');

        // Owner can always see their workshops
        try {
          final workshop = WorkshopModel.fromJson({
            ...data,
            'id': workshopId,
          });
          workshops.add(workshop);
          
          Logger.repository('READ', 'workshops', {
            'workshop_id': workshopId,
            'user_id': userId,
            'is_owner': true,
          });
        } catch (e) {
          Logger.error('Error converting workshop data: $e');
        }
      }

      // Also check workshop_staff collection for workshops where user is staff (not owner)
      try {
        final staffSnapshot = await firestore
            .collection('workshop_staff')
            .where('user_id', isEqualTo: userId)
            .get();

        Logger.info('Found ${staffSnapshot.docs.length} staff records for user');

        for (var staffDoc in staffSnapshot.docs) {
          final workshopId = staffDoc.get('workshop_id') as String?;
          
          if (workshopId != null && workshopId.isNotEmpty) {
            // Check if this workshop is already in the list (if user is also owner)
            final existingIndex = workshops.indexWhere((w) => w.id == workshopId);
            
            if (existingIndex == -1) {
              // Workshop not in list, fetch it
              try {
                final workshopDoc = await firestore
                    .collection('workshops')
                    .doc(workshopId)
                    .get();

                if (workshopDoc.exists) {
                  final workshop = WorkshopModel.fromJson({
                    ...workshopDoc.data()!,
                    'id': workshopId,
                  });
                  workshops.add(workshop);
                  
                  final compositeKey = '${userId}_$workshopId';
                  Logger.repository('READ', 'workshop_staff', {
                    'composite_key': compositeKey,
                    'workshop_id': workshopId,
                    'is_staff': true,
                  });
                }
              } catch (e) {
                Logger.error('Error fetching workshop $workshopId: $e');
              }
            }
          }
        }
      } catch (e) {
        Logger.error('Error fetching staff records: $e');
      }

      Logger.repository('READ_QUERY', 'workshops', {
        'user_id': userId,
        'total_count': workshops.length,
      });
      
      return Right(workshops);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error fetching workshops: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to fetch workshops'));
    } catch (e) {
      Logger.error('Error fetching workshops: $e');
      return Left(ServerFailure('Failed to fetch workshops: $e'));
    }
  }

  /// Get single workshop by ID
  Future<Either<Failure, WorkshopModel>> getWorkshop(String workshopId) async {
    try {
      Logger.info('Fetching workshop: $workshopId');

      final doc = await firestore.collection('workshops').doc(workshopId).get();

      if (!doc.exists) {
        return const Left(NotFoundFailure('Workshop not found'));
      }

      return Right(WorkshopModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      }));
    } on FirebaseException catch (e) {
      Logger.error('Firebase error fetching workshop: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to fetch workshop'));
    } catch (e) {
      Logger.error('Error fetching workshop: $e');
      return Left(ServerFailure('Failed to fetch workshop: $e'));
    }
  }

  /// Update workshop
  Future<Either<Failure, void>> updateWorkshop({
    required String workshopId,
    required String name,
    required String location,
  }) async {
    try {
      Logger.info('Updating workshop: $workshopId');

      await firestore.collection('workshops').doc(workshopId).update({
        'name': name,
        'location': location,
        'updated_at': DateTime.now(),
      });

      Logger.repository('UPDATE', 'workshops', {'workshop_id': workshopId});
      return const Right(null);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error updating workshop: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to update workshop'));
    } catch (e) {
      Logger.error('Error updating workshop: $e');
      return Left(ServerFailure('Failed to update workshop: $e'));
    }
  }

  /// Delete workshop (only owner can delete)
  Future<Either<Failure, void>> deleteWorkshop(String workshopId) async {
    try {
      Logger.info('Deleting workshop: $workshopId');

      // Delete all staff records in transaction
      await firestore.runTransaction<void>((transaction) async {
        // Get all staff documents
        final staffSnapshot = await firestore
            .collection('workshops')
            .doc(workshopId)
            .collection('staff')
            .get();

        // Delete each staff document
        for (var staffDoc in staffSnapshot.docs) {
          transaction.delete(staffDoc.reference);
        }

        // Delete workshop document
        transaction.delete(
          firestore.collection('workshops').doc(workshopId),
        );
      });

      Logger.repository('DELETE', 'workshops', {'workshop_id': workshopId});
      return const Right(null);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error deleting workshop: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to delete workshop'));
    } catch (e) {
      Logger.error('Error deleting workshop: $e');
      return Left(ServerFailure('Failed to delete workshop: $e'));
    }
  }

  /// Get workshop staff list
  Future<Either<Failure, List<Map<String, dynamic>>>> getWorkshopStaff(
    String workshopId,
  ) async {
    try {
      Logger.info('Fetching workshop staff: $workshopId');

      final staffSnapshot = await firestore
          .collection('workshops')
          .doc(workshopId)
          .collection('staff')
          .get();

      final staffList = staffSnapshot.docs.map((doc) => doc.data()).toList();

      Logger.repository(
        'READ_QUERY',
        'workshop_staff',
        {'workshop_id': workshopId},
      );
      return Right(staffList);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error fetching workshop staff: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to fetch workshop staff'));
    } catch (e) {
      Logger.error('Error fetching workshop staff: $e');
      return Left(ServerFailure('Failed to fetch workshop staff: $e'));
    }
  }
}
