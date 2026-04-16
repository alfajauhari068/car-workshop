import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_workshop/core/utils/logger_util.dart';

/// Permission Service for comprehensive access control
/// Handles:
/// 1. Membership verification
/// 2. Role-based permissions
/// 3. Resource ownership validation
class PermissionService {
  final FirebaseFirestore _firestore;

  PermissionService(this._firestore);

  // ============================================================================
  // PART 1: MEMBERSHIP VERIFICATION
  // ============================================================================

  /// Check if user is member of workshop
  /// Requirements: user_id + workshop_id in workshop_staff collection
  Future<bool> checkMembership({
    required String userId,
    required String workshopId,
  }) async {
    try {
      Logger.info(
        'PERMISSION: Checking membership - user=$userId, workshop=$workshopId',
      );

      if (userId.isEmpty || workshopId.isEmpty) {
        Logger.error('PERMISSION: Empty userId or workshopId');
        return false;
      }

      final query = await _firestore
          .collection('workshop_staff')
          .where('user_id', isEqualTo: userId)
          .where('workshop_id', isEqualTo: workshopId)
          .limit(1)
          .get();

      final isMember = query.docs.isNotEmpty;

      if (isMember) {
        Logger.repository(
          'PERMISSION_CHECK',
          'membership',
          {'user_id': userId, 'workshop_id': workshopId, 'result': 'pass'},
        );
      } else {
        Logger.warning(
          'PERMISSION: User is not member of workshop - $userId in $workshopId',
        );
      }

      return isMember;
    } catch (e) {
      Logger.error('PERMISSION: Membership check failed - $e');
      return false;
    }
  }

  // ============================================================================
  // PART 2: ROLE VERIFICATION
  // ============================================================================

  /// Get user's role in specific workshop
  /// Returns: 'mechanic', 'manager', 'owner', or null
  Future<String?> getUserRole({
    required String userId,
    required String workshopId,
  }) async {
    try {
      Logger.info(
        'PERMISSION: Getting role - user=$userId, workshop=$workshopId',
      );

      if (userId.isEmpty || workshopId.isEmpty) {
        Logger.error('PERMISSION: Empty userId or workshopId');
        return null;
      }

      final query = await _firestore
          .collection('workshop_staff')
          .where('user_id', isEqualTo: userId)
          .where('workshop_id', isEqualTo: workshopId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        Logger.warning('PERMISSION: No role found for user in workshop');
        return null;
      }

      final role = query.docs.first.get('role') as String?;

      Logger.repository(
        'PERMISSION_CHECK',
        'role_retrieval',
        {'user_id': userId, 'workshop_id': workshopId, 'role': role},
      );

      return role;
    } catch (e) {
      Logger.error('PERMISSION: Role retrieval failed - $e');
      return null;
    }
  }

  /// Check if user is owner of workshop
  Future<bool> isOwner({
    required String userId,
    required String workshopId,
  }) async {
    try {
      Logger.info(
        'PERMISSION: Checking owner - user=$userId, workshop=$workshopId',
      );

      final role = await getUserRole(userId: userId, workshopId: workshopId);
      final isOwner = role == 'owner';

      if (isOwner) {
        Logger.repository(
          'PERMISSION_CHECK',
          'owner_check',
          {'user_id': userId, 'workshop_id': workshopId, 'result': 'pass'},
        );
      }

      return isOwner;
    } catch (e) {
      Logger.error('PERMISSION: Owner check failed - $e');
      return false;
    }
  }

  /// Check if user is manager or owner
  Future<bool> isManagerOrAbove({
    required String userId,
    required String workshopId,
  }) async {
    try {
      Logger.info(
        'PERMISSION: Checking manager+ - user=$userId, workshop=$workshopId',
      );

      final role = await getUserRole(userId: userId, workshopId: workshopId);
      final isManagerOrAbove = role == 'manager' || role == 'owner';

      if (isManagerOrAbove) {
        Logger.repository(
          'PERMISSION_CHECK',
          'manager_check',
          {'user_id': userId, 'workshop_id': workshopId, 'result': 'pass'},
        );
      }

      return isManagerOrAbove;
    } catch (e) {
      Logger.error('PERMISSION: Manager check failed - $e');
      return false;
    }
  }

  // ============================================================================
  // PART 3: RESOURCE OWNERSHIP VERIFICATION
  // ============================================================================

  /// Check if branch belongs to workshop
  /// Path: workshops/{workshopId}/branches/{branchId}
  Future<bool> branchBelongsToWorkshop({
    required String workshopId,
    required String branchId,
  }) async {
    try {
      Logger.info(
        'PERMISSION: Checking branch ownership - workshop=$workshopId, branch=$branchId',
      );

      if (workshopId.isEmpty || branchId.isEmpty) {
        Logger.error('PERMISSION: Empty workshopId or branchId');
        return false;
      }

      final branchDoc = await _firestore
          .collection('workshops')
          .doc(workshopId)
          .collection('branches')
          .doc(branchId)
          .get();

      final belongs = branchDoc.exists;

      if (belongs) {
        Logger.repository(
          'PERMISSION_CHECK',
          'branch_ownership',
          {'workshop_id': workshopId, 'branch_id': branchId, 'result': 'pass'},
        );
      } else {
        Logger.warning(
          'PERMISSION: Branch does not belong to workshop - $branchId in $workshopId',
        );
      }

      return belongs;
    } catch (e) {
      Logger.error('PERMISSION: Branch ownership check failed - $e');
      return false;
    }
  }

  /// Check if service belongs to workshop
  /// Path: workshops/{workshopId}/services/{serviceId}
  Future<bool> serviceBelongsToWorkshop({
    required String workshopId,
    required String serviceId,
  }) async {
    try {
      Logger.info(
        'PERMISSION: Checking service ownership - workshop=$workshopId, service=$serviceId',
      );

      if (workshopId.isEmpty || serviceId.isEmpty) {
        Logger.error('PERMISSION: Empty workshopId or serviceId');
        return false;
      }

      final serviceDoc = await _firestore
          .collection('workshops')
          .doc(workshopId)
          .collection('services')
          .doc(serviceId)
          .get();

      final belongs = serviceDoc.exists;

      if (belongs) {
        Logger.repository(
          'PERMISSION_CHECK',
          'service_ownership',
          {'workshop_id': workshopId, 'service_id': serviceId, 'result': 'pass'},
        );
      } else {
        Logger.warning(
          'PERMISSION: Service does not belong to workshop - $serviceId in $workshopId',
        );
      }

      return belongs;
    } catch (e) {
      Logger.error('PERMISSION: Service ownership check failed - $e');
      return false;
    }
  }

  /// Check if booking belongs to workshop
  /// Path: workshops/{workshopId}/bookings/{bookingId}
  Future<bool> bookingBelongsToWorkshop({
    required String workshopId,
    required String bookingId,
  }) async {
    try {
      Logger.info(
        'PERMISSION: Checking booking ownership - workshop=$workshopId, booking=$bookingId',
      );

      if (workshopId.isEmpty || bookingId.isEmpty) {
        Logger.error('PERMISSION: Empty workshopId or bookingId');
        return false;
      }

      final bookingDoc = await _firestore
          .collection('workshops')
          .doc(workshopId)
          .collection('bookings')
          .doc(bookingId)
          .get();

      final belongs = bookingDoc.exists;

      if (belongs) {
        Logger.repository(
          'PERMISSION_CHECK',
          'booking_ownership',
          {'workshop_id': workshopId, 'booking_id': bookingId, 'result': 'pass'},
        );
      } else {
        Logger.warning(
          'PERMISSION: Booking does not belong to workshop - $bookingId in $workshopId',
        );
      }

      return belongs;
    } catch (e) {
      Logger.error('PERMISSION: Booking ownership check failed - $e');
      return false;
    }
  }

  // ============================================================================
  // PART 4: COMBINED PERMISSION CHECKS
  // ============================================================================

  /// Complete permission check: Membership + Role + Resource
  /// 1. Check user is member
  /// 2. Check user has required role
  /// 3. Optionally verify resource belongs to workshop
  Future<bool> canAccess({
    required String userId,
    required String workshopId,
    required String action, // 'view', 'edit', 'delete', 'manage_staff'
    String? resourceId,
    String? resourceType, // 'branch', 'service', 'booking'
  }) async {
    try {
      Logger.info(
        'PERMISSION: Complete check - user=$userId, workshop=$workshopId, action=$action, resource=$resourceType:$resourceId',
      );

      // STEP 1: Check membership
      final isMember = await checkMembership(
        userId: userId,
        workshopId: workshopId,
      );
      if (!isMember) {
        Logger.warning('PERMISSION: Access denied - not a member');
        return false;
      }

      // STEP 2: Check role-based permission
      final role = await getUserRole(userId: userId, workshopId: workshopId);
      if (role == null) {
        Logger.warning('PERMISSION: Access denied - no role');
        return false;
      }

      // Define role-based permissions
      final permissions = {
        'owner': [
          'view',
          'edit',
          'delete',
          'manage_staff',
          'analytics',
          'settings',
        ],
        'manager': [
          'view',
          'edit',
          'manage_staff',
        ],
        'mechanic': [
          'view',
        ],
      };

      final hasRolePermission = permissions[role]?.contains(action) ?? false;
      if (!hasRolePermission) {
        Logger.warning(
          'PERMISSION: Access denied - $role cannot perform $action',
        );
        return false;
      }

      // STEP 3: Check resource ownership (optional)
      if (resourceId != null && resourceType != null) {
        bool resourceBelongs = false;

        if (resourceType == 'branch') {
          resourceBelongs = await branchBelongsToWorkshop(
            workshopId: workshopId,
            branchId: resourceId,
          );
        } else if (resourceType == 'service') {
          resourceBelongs = await serviceBelongsToWorkshop(
            workshopId: workshopId,
            serviceId: resourceId,
          );
        } else if (resourceType == 'booking') {
          resourceBelongs = await bookingBelongsToWorkshop(
            workshopId: workshopId,
            bookingId: resourceId,
          );
        }

        if (!resourceBelongs) {
          Logger.warning(
            'PERMISSION: Access denied - resource does not belong to workshop',
          );
          return false;
        }
      }

      // All checks passed
      Logger.repository(
        'PERMISSION_CHECK',
        'complete_access',
        {
          'user_id': userId,
          'workshop_id': workshopId,
          'action': action,
          'resource_type': resourceType,
          'result': 'pass',
        },
      );

      return true;
    } catch (e) {
      Logger.error('PERMISSION: Complete check failed - $e');
      return false;
    }
  }

  /// Batch permission check for multiple resources
  Future<Map<String, bool>> canAccessBatch({
    required String userId,
    required String workshopId,
    required String action,
    required List<Map<String, String>> resources,
  }) async {
    try {
      Logger.info(
        'PERMISSION: Batch check - user=$userId, action=$action, resources=${resources.length}',
      );

      final results = <String, bool>{};

      for (final resource in resources) {
        final resourceId = resource['id'] ?? '';
        final resourceType = resource['type'] ?? '';

        if (resourceId.isEmpty || resourceType.isEmpty) continue;

        final hasAccess = await canAccess(
          userId: userId,
          workshopId: workshopId,
          action: action,
          resourceId: resourceId,
          resourceType: resourceType,
        );

        results[resourceId] = hasAccess;
      }

      Logger.repository(
        'PERMISSION_CHECK',
        'batch_access',
        {'worksheet_id': workshopId, 'results': results.length},
      );

      return results;
    } catch (e) {
      Logger.error('PERMISSION: Batch check failed - $e');
      return {};
    }
  }

  // ============================================================================
  // PART 5: ACTION-SPECIFIC PERMISSION HELPERS
  // ============================================================================

  /// Can user view workshop data
  Future<bool> canViewWorkshop({
    required String userId,
    required String workshopId,
  }) async {
    return canAccess(
      userId: userId,
      workshopId: workshopId,
      action: 'view',
    );
  }

  /// Can user edit workshop resources
  Future<bool> canEditWorkshop({
    required String userId,
    required String workshopId,
  }) async {
    return canAccess(
      userId: userId,
      workshopId: workshopId,
      action: 'edit',
    );
  }

  /// Can user delete workshop resources
  Future<bool> canDeleteWorkshop({
    required String userId,
    required String workshopId,
  }) async {
    return canAccess(
      userId: userId,
      workshopId: workshopId,
      action: 'delete',
    );
  }

  /// Can user manage staff
  Future<bool> canManageStaff({
    required String userId,
    required String workshopId,
  }) async {
    return canAccess(
      userId: userId,
      workshopId: workshopId,
      action: 'manage_staff',
    );
  }

  /// Can user view analytics
  Future<bool> canViewAnalytics({
    required String userId,
    required String workshopId,
  }) async {
    return canAccess(
      userId: userId,
      workshopId: workshopId,
      action: 'analytics',
    );
  }

  /// Can user access branch
  Future<bool> canAccessBranch({
    required String userId,
    required String workshopId,
    required String branchId,
    required String action,
  }) async {
    return canAccess(
      userId: userId,
      workshopId: workshopId,
      action: action,
      resourceId: branchId,
      resourceType: 'branch',
    );
  }

  /// Can user access service
  Future<bool> canAccessService({
    required String userId,
    required String workshopId,
    required String serviceId,
    required String action,
  }) async {
    return canAccess(
      userId: userId,
      workshopId: workshopId,
      action: action,
      resourceId: serviceId,
      resourceType: 'service',
    );
  }

  /// Can user access booking
  Future<bool> canAccessBooking({
    required String userId,
    required String workshopId,
    required String bookingId,
    required String action,
  }) async {
    return canAccess(
      userId: userId,
      workshopId: workshopId,
      action: action,
      resourceId: bookingId,
      resourceType: 'booking',
    );
  }
}
