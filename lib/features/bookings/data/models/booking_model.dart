import 'package:car_workshop/features/bookings/domain/entities/booking_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore Timestamp

import '../../../auth/data/models/user_model.dart';
import 'car_model.dart';
import 'customer_model.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.workshopId,
    required super.branchId,
    required super.serviceId,
    required CarModel super.car,
    required CustomerModel super.customer,
    required super.title,
    required super.startDateTime,
    required super.endDateTime,
    required UserModel super.mechanic,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      workshopId: json['workshop_id'] as String,
      branchId: json['branch_id'] as String,
      serviceId: json['service_id'] as String,
      car: CarModel.fromJson(json['car'] as Map<String, dynamic>),
      customer:
          CustomerModel.fromJson(json['customer'] as Map<String, dynamic>),
      title: json['title'] as String,
      startDateTime: (json['startDateTime'] as Timestamp).toDate(),
      endDateTime: (json['endDateTime'] as Timestamp).toDate(),
      mechanic: UserModel.fromJson(json['mechanic'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workshop_id': workshopId,
      'branch_id': branchId,
      'service_id': serviceId,
      'car': (car as CarModel).toJson(),
      'customer': (customer as CustomerModel).toJson(),
      'title': title,
      'startDateTime': Timestamp.fromDate(startDateTime),
      'endDateTime': Timestamp.fromDate(endDateTime),
      'mechanic': (mechanic as UserModel).toJson(),
    };
  }

  BookingEntity toEntity() {
    return BookingEntity(
      id: id,
      workshopId: workshopId,
      branchId: branchId,
      serviceId: serviceId,
      car: (car as CarModel).toEntity(),
      customer: (customer as CustomerModel).toEntity(),
      title: title,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      mechanic: (mechanic as UserModel).toEntity(),
    );
  }
}
