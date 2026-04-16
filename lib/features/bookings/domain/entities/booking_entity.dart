import 'package:car_workshop/features/bookings/data/models/booking_model.dart';
import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user_entity.dart';
import 'car_entity.dart';
import 'customer_entity.dart';

class BookingEntity extends Equatable {
  final String id;
  final String workshopId;
  final String branchId;
  final String serviceId;
  final CarEntity car;
  final CustomerEntity customer;
  final String title;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final UserEntity mechanic;

  const BookingEntity({
    required this.id,
    required this.workshopId,
    required this.branchId,
    required this.serviceId,
    required this.car,
    required this.customer,
    required this.title,
    required this.startDateTime,
    required this.endDateTime,
    required this.mechanic,
  });

  @override
  List<Object> get props => [
        id,
        workshopId,
        branchId,
        serviceId,
        car,
        customer,
        title,
        startDateTime,
        endDateTime,
        mechanic,
      ];

  BookingModel toModel() {
    return BookingModel(
      id: id,
      workshopId: workshopId,
      branchId: branchId,
      serviceId: serviceId,
      car: car.toModel(),
      customer: customer.toModel(),
      title: title,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      mechanic: mechanic.toModel(),
    );
  }

  BookingEntity copyWith({
    String? id,
    String? workshopId,
    String? branchId,
    String? serviceId,
    CarEntity? car,
    CustomerEntity? customer,
    String? title,
    DateTime? startDateTime,
    DateTime? endDateTime,
    UserEntity? mechanic,
  }) {
    return BookingEntity(
      id: id ?? this.id,
      workshopId: workshopId ?? this.workshopId,
      branchId: branchId ?? this.branchId,
      serviceId: serviceId ?? this.serviceId,
      car: car ?? this.car,
      customer: customer ?? this.customer,
      title: title ?? this.title,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      mechanic: mechanic ?? this.mechanic,
    );
  }
}
