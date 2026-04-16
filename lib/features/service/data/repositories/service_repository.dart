import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:car_workshop/core/errors/failure.dart';
import 'package:car_workshop/core/utils/logger_util.dart';
import '../models/service_model.dart';

class ServiceRepository {
  final FirebaseFirestore firestore;

  ServiceRepository(this.firestore);

  /// Create new service for a workshop
  Future<Either<Failure, ServiceModel>> createService({
    required String workshopId,
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
  }) async {
    try {
      Logger.info(
        'Creating service: $name for workshop: $workshopId',
      );

      // Validate inputs
      if (name.isEmpty || description.isEmpty) {
        return const Left(InputFailure('Name and description are required'));
      }
      if (price < 0 || durationMinutes <= 0) {
        return const Left(InputFailure('Price must be >= 0 and duration > 0'));
      }

      // Create service under workshops/{workshopId}/services/{serviceId}
      final serviceRef = firestore
          .collection('workshops')
          .doc(workshopId)
          .collection('services')
          .doc();

      final now = DateTime.now();
      final serviceModel = ServiceModel(
        id: serviceRef.id,
        name: name,
        description: description,
        price: price,
        durationMinutes: durationMinutes,
        workshopId: workshopId,
        createdAt: now,
        updatedAt: now,
      );

      await serviceRef.set(serviceModel.toJson());

      Logger.repository(
        'CREATE',
        'services',
        {
          'service_id': serviceRef.id,
          'workshop_id': workshopId,
          'name': name,
          'price': price,
        },
      );

      return Right(serviceModel);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error creating service: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to create service'));
    } catch (e) {
      Logger.error('Error creating service: $e');
      return Left(ServerFailure('Failed to create service: $e'));
    }
  }

  /// Get all services for a workshop
  Future<Either<Failure, List<ServiceModel>>> getServicesForWorkshop(
    String workshopId,
  ) async {
    try {
      Logger.info('Fetching services for workshop: $workshopId');

      final serviceSnapshot = await firestore
          .collection('workshops')
          .doc(workshopId)
          .collection('services')
          .orderBy('created_at', descending: true)
          .get();

      final services = serviceSnapshot.docs
          .map((doc) => ServiceModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();

      Logger.repository(
        'READ_QUERY',
        'services',
        {'workshop_id': workshopId, 'count': services.length},
      );

      return Right(services);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error fetching services: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to fetch services'));
    } catch (e) {
      Logger.error('Error fetching services: $e');
      return Left(ServerFailure('Failed to fetch services: $e'));
    }
  }

  /// Get single service by ID
  Future<Either<Failure, ServiceModel>> getService({
    required String workshopId,
    required String serviceId,
  }) async {
    try {
      Logger.info('Fetching service: $serviceId from workshop: $workshopId');

      final doc = await firestore
          .collection('workshops')
          .doc(workshopId)
          .collection('services')
          .doc(serviceId)
          .get();

      if (!doc.exists) {
        return const Left(NotFoundFailure('Service not found'));
      }

      return Right(ServiceModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      }));
    } on FirebaseException catch (e) {
      Logger.error('Firebase error fetching service: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to fetch service'));
    } catch (e) {
      Logger.error('Error fetching service: $e');
      return Left(ServerFailure('Failed to fetch service: $e'));
    }
  }

  /// Update service
  Future<Either<Failure, void>> updateService({
    required String workshopId,
    required String serviceId,
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
  }) async {
    try {
      Logger.info('Updating service: $serviceId in workshop: $workshopId');

      if (name.isEmpty || description.isEmpty) {
        return const Left(InputFailure('Name and description are required'));
      }
      if (price < 0 || durationMinutes <= 0) {
        return const Left(InputFailure('Price must be >= 0 and duration > 0'));
      }

      await firestore
          .collection('workshops')
          .doc(workshopId)
          .collection('services')
          .doc(serviceId)
          .update({
        'name': name,
        'description': description,
        'price': price,
        'duration_minutes': durationMinutes,
        'updated_at': DateTime.now(),
      });

      Logger.repository(
        'UPDATE',
        'services',
        {'service_id': serviceId, 'workshop_id': workshopId},
      );

      return const Right(null);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error updating service: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to update service'));
    } catch (e) {
      Logger.error('Error updating service: $e');
      return Left(ServerFailure('Failed to update service: $e'));
    }
  }

  /// Delete service
  Future<Either<Failure, void>> deleteService({
    required String workshopId,
    required String serviceId,
  }) async {
    try {
      Logger.info('Deleting service: $serviceId from workshop: $workshopId');

      await firestore
          .collection('workshops')
          .doc(workshopId)
          .collection('services')
          .doc(serviceId)
          .delete();

      Logger.repository(
        'DELETE',
        'services',
        {'service_id': serviceId, 'workshop_id': workshopId},
      );

      return const Right(null);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error deleting service: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to delete service'));
    } catch (e) {
      Logger.error('Error deleting service: $e');
      return Left(ServerFailure('Failed to delete service: $e'));
    }
  }

  /// Get service count for workshop
  Future<Either<Failure, int>> getServiceCount(String workshopId) async {
    try {
      final snapshot = await firestore
          .collection('workshops')
          .doc(workshopId)
          .collection('services')
          .count()
          .get();

      return Right(snapshot.count ?? 0);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error counting services: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to count services'));
    } catch (e) {
      Logger.error('Error counting services: $e');
      return Left(ServerFailure('Failed to count services: $e'));
    }
  }
}
