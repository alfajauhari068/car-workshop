import 'package:car_workshop/core/errors/failure.dart';
import 'package:car_workshop/core/utils/logger_util.dart';
import 'package:car_workshop/features/bookings/data/datasources/booking_remote_data_source.dart';
import 'package:car_workshop/features/bookings/data/models/booking_model.dart';
import 'package:car_workshop/features/bookings/domain/entities/booking_entity.dart';
import 'package:car_workshop/features/bookings/domain/repositories/booking_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;
  final FirebaseFirestore firestore;

  BookingRepositoryImpl(this.remoteDataSource, this.firestore);

  /// Validate that workshop exists
  Future<Either<Failure, bool>> _validateWorkshopExists(
      String workshopId) async {
    try {
      Logger.info('Validating workshop exists: $workshopId');
      final workshopDoc =
          await firestore.collection('workshops').doc(workshopId).get();

      if (!workshopDoc.exists) {
        Logger.error('Workshop not found: $workshopId');
        return const Left(ServerFailure('Workshop does not exist'));
      }

      Logger.repository(
        'VALIDATE',
        'workshops',
        {'workshop_id': workshopId, 'exists': true},
      );
      return const Right(true);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error validating workshop: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to validate workshop'));
    } catch (e) {
      Logger.error('Error validating workshop: $e');
      return Left(ServerFailure('Failed to validate workshop: $e'));
    }
  }

  /// Validate that branch belongs to workshop
  Future<Either<Failure, bool>> _validateBranchBelongsToWorkshop(
    String workshopId,
    String branchId,
  ) async {
    try {
      Logger.info(
        'Validating branch: $branchId belongs to workshop: $workshopId',
      );

      final branchDoc = await firestore
          .collection('workshops')
          .doc(workshopId)
          .collection('branches')
          .doc(branchId)
          .get();

      if (!branchDoc.exists) {
        Logger.error(
          'Branch not found or does not belong to workshop: branch_id=$branchId, workshop_id=$workshopId',
        );
        return const Left(ServerFailure(
          'Branch does not belong to this workshop',
        ));
      }

      Logger.repository(
        'VALIDATE',
        'branches',
        {
          'workshop_id': workshopId,
          'branch_id': branchId,
          'belongs': true,
        },
      );
      return const Right(true);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error validating branch: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to validate branch'));
    } catch (e) {
      Logger.error('Error validating branch: $e');
      return Left(ServerFailure('Failed to validate branch: $e'));
    }
  }

  /// Validate that service belongs to workshop
  Future<Either<Failure, bool>> _validateServiceBelongsToWorkshop(
    String workshopId,
    String serviceId,
  ) async {
    try {
      Logger.info(
        'Validating service: $serviceId belongs to workshop: $workshopId',
      );

      final serviceDoc = await firestore
          .collection('workshops')
          .doc(workshopId)
          .collection('services')
          .doc(serviceId)
          .get();

      if (!serviceDoc.exists) {
        Logger.error(
          'Service not found or does not belong to workshop: service_id=$serviceId, workshop_id=$workshopId',
        );
        return const Left(ServerFailure(
          'Service does not belong to this workshop',
        ));
      }

      Logger.repository(
        'VALIDATE',
        'services',
        {
          'workshop_id': workshopId,
          'service_id': serviceId,
          'belongs': true,
        },
      );
      return const Right(true);
    } on FirebaseException catch (e) {
      Logger.error('Firebase error validating service: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to validate service'));
    } catch (e) {
      Logger.error('Error validating service: $e');
      return Left(ServerFailure('Failed to validate service: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addBooking(BookingEntity booking) async {
    try {
      Logger.info(
        'Adding booking - workshop: ${booking.workshopId}, branch: ${booking.branchId}, service: ${booking.serviceId}',
      );

      // Validate null safety
      if (booking.id.isEmpty ||
          booking.workshopId.isEmpty ||
          booking.branchId.isEmpty ||
          booking.serviceId.isEmpty) {
        Logger.error('Booking has empty IDs');
        return const Left(InputFailure('Booking IDs cannot be empty'));
      }

      // ✔ Validate workshop exists
      final workshopValidation =
          await _validateWorkshopExists(booking.workshopId);
      if (workshopValidation.isLeft()) {
        return workshopValidation.fold(
          (failure) => Left<Failure, void>(failure),
          (_) => const Right(null),
        );
      }

      // ✔ Validate branch belongs to workshop
      final branchValidation = await _validateBranchBelongsToWorkshop(
        booking.workshopId,
        booking.branchId,
      );
      if (branchValidation.isLeft()) {
        return branchValidation.fold(
          (failure) => Left<Failure, void>(failure),
          (_) => const Right(null),
        );
      }

      // ✔ Validate service belongs to workshop
      final serviceValidation = await _validateServiceBelongsToWorkshop(
        booking.workshopId,
        booking.serviceId,
      );
      if (serviceValidation.isLeft()) {
        return serviceValidation.fold(
          (failure) => Left<Failure, void>(failure),
          (_) => const Right(null),
        );
      }

      final bookingModel = BookingModel(
        id: booking.id,
        workshopId: booking.workshopId,
        branchId: booking.branchId,
        serviceId: booking.serviceId,
        car: booking.car.toModel(),
        customer: booking.customer.toModel(),
        title: booking.title,
        startDateTime: booking.startDateTime,
        endDateTime: booking.endDateTime,
        mechanic: booking.mechanic.toModel(),
      );

      await remoteDataSource.addBooking(bookingModel);

      Logger.repository(
        'CREATE',
        'bookings',
        {
          'booking_id': booking.id,
          'workshop_id': booking.workshopId,
          'branch_id': booking.branchId,
          'service_id': booking.serviceId,
        },
      );

      return const Right(null);
    } catch (error) {
      Logger.error('Error adding booking: $error');
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> fetchBookings() async {
    final result = await remoteDataSource.fetchBookings();
    return result.map((bookingModels) =>
        bookingModels.map((model) => model.toEntity()).toList());
  }

  @override
  Future<Either<Failure, BookingEntity?>> getBookingById(String id) async {
    final result = await remoteDataSource.getBookingById(id);
    return result.map((bookingModel) => bookingModel?.toEntity());
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getBookingsByMechanic(
      String mechanicId) async {
    final result = await remoteDataSource.getBookingsByMechanic(mechanicId);
    return result.map((bookingModels) =>
        bookingModels.map((model) => model.toEntity()).toList());
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> fetchBookingsForDay(
      DateTime date) async {
    final result = await remoteDataSource.getBookingsByDate(date);
    return result.map((bookingModels) =>
        bookingModels.map((model) => model.toEntity()).toList());
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> fetchBookingsInRange(
      DateTime fromDate, DateTime toDate) async {
    final result = await remoteDataSource.getBookingsInRange(fromDate, toDate);
    return result.map((bookingModels) =>
        bookingModels.map((model) => model.toEntity()).toList());
  }

  @override
  Future<Either<Failure, void>> deleteBooking(String id) async {
    try {
      await remoteDataSource.deleteBooking(id);
      return const Right(null);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }
}
