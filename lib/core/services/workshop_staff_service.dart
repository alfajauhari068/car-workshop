import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_workshop/core/utils/logger_util.dart';

/// Service for checking user membership and permissions in workshops
/// WAJIB LOGIC:
/// 1. Check membership (user is in workshop_staff collection)
/// 2. Check role (owner/manager/mechanic)
/// 3. Verify resource ownership (resource belongs to workshop)
///
/// Critical for multi-workshop support and security
/// FLAT COLLECTION: workshop_staff/{userId}_{workshopId}
class WorkshopStaffService {
  final FirebaseFirestore _firestore;

  WorkshopStaffService(this._firestore);

  // ============================================================================
  // PERMISSION MATRIX
  // ============================================================================

  /// Define permissions per role (owner, manager, mechanic)
  static const Map<String, List<String>> rolePermissions = {
    'owner': [
      'create',
      'edit',
      'delete',
      'assign',
      'view',
      'manage_staff',
      'analytics',
      'settings',
      'invite_staff',
    ],
    'manager': [
      'edit',
      'assign',
      'view',
      'manage_staff',
      'analytics',
      'invite_staff',
    ],
    'mechanic': [
      'view',
      'update_progress',
    ],
  };

  // ============================================================================
  // PART 1: MEMBERSHIP CHECK (WAJIB)
  // ============================================================================

  /// Check if user is member of workshop
  /// WAJIB: Verifies user exists in workshop_staff FLAT collection
  /// Document ID format: '{userId}_{workshopId}' (composite key)
  Future<bool> isMemberOfWorkshop(String userId, String workshopId) async {
    try {
      Logger.info(
        'MEMBERSHIP: Checking if user is member - userId=$userId, workshopId=$workshopId',
      );

      if (userId.isEmpty || workshopId.isEmpty) {
        Logger.error('MEMBERSHIP: Empty userId or workshopId');
        return false;
      }

      // Query FLAT collection with composite key: '{userId}_{workshopId}'
      final staffDocId = '${userId}_$workshopId';
      final staffDoc = await _firestore
          .collection('workshop_staff')
          .doc(staffDocId)
          .get();

      final isMember = staffDoc.exists;

      if (isMember) {
        Logger.repository(
          'MEMBERSHIP_CHECK',
          'workshop_staff',
          {
            'user_id': userId,
            'workshop_id': workshopId,
            'result': 'member',
            'staff_doc_id': staffDocId,
          },
        );
      } else {
        Logger.warning(
          'MEMBERSHIP: User is not member of workshop - $userId in $workshopId',
        );
      }

      return isMember;
    } catch (e) {
      Logger.error('MEMBERSHIP: Check failed - $e');
      return false;
    }
  }

  // ============================================================================
  // PART 2: ROLE CHECK (WAJIB)
  // ============================================================================

  /// Get user's role in specific workshop
  /// WAJIB: Returns 'owner', 'manager', 'mechanic', or null
  /// Queries FLAT collection with composite key
  Future<String?> getUserRoleInWorkshop(String userId, String workshopId) async {
    try {
      Logger.info(
        'ROLE: Getting user role - userId=$userId, workshopId=$workshopId',
      );

      if (userId.isEmpty || workshopId.isEmpty) {
        Logger.error('ROLE: Empty userId or workshopId');
        return null;
      }

      // Query FLAT collection with composite key
      final staffDocId = '${userId}_$workshopId';
      final staffDoc = await _firestore
          .collection('workshop_staff')
          .doc(staffDocId)
          .get();

      if (!staffDoc.exists) {
        Logger.warning('ROLE: No role found for user in workshop');
        return null;
      }

      final role = staffDoc.get('role') as String?;

      Logger.repository(
        'ROLE_CHECK',
        'workshop_staff',
        {
          'user_id': userId,
          'workshop_id': workshopId,
          'role': role,
          'staff_doc_id': staffDocId,
        },
      );

      return role;
    } catch (e) {
      Logger.error('ROLE: Retrieval failed - $e');
      return null;
    }
  }

  // ============================================================================
  // PART 3: RESOURCE OWNERSHIP CHECK (WAJIB)
  // ============================================================================

  /// Check if resource (branch/service/booking) belongs to workshop
  /// WAJIB: Verifies resource exists under workshop path
  Future<bool> resourceBelongsToWorkshop({
    required String workshopId,
    required String resourceId,
    required String resourceType, // 'branch', 'service', 'booking'
  }) async {
    try {
      Logger.info(
        'OWNERSHIP: Checking $resourceType ownership - workshop=$workshopId, resource=$resourceId',
      );

      if (workshopId.isEmpty || resourceId.isEmpty) {
        Logger.error('OWNERSHIP: Empty workshopId or resourceId');
        return false;
      }

      final resourcePath = '$resourceType/$resourceId';
      Logger.info('OWNERSHIP: Checking path - $resourcePath');

      final resourceDoc = await _firestore
          .collection(resourceType)
          .doc(resourceId)
          .get();

      if (!resourceDoc.exists) {
        Logger.warning(
          'OWNERSHIP: Resource does not exist - $resourceType:$resourceId',
        );
        return false;
      }

      // Check if workshop_id in resource matches
      final resourceWorkshopId = resourceDoc.get('workshop_id') as String?;
      final belongs = resourceWorkshopId == workshopId;

      if (belongs) {
        Logger.repository(
          'OWNERSHIP_CHECK',
          resourceType,
          {
            'workshop_id': workshopId,
            'resource_id': resourceId,
            'result': 'belongs',
          },
        );
      } else {
        Logger.warning(
          'OWNERSHIP: Resource does not belong to workshop - $resourceType:$resourceId in $workshopId',
        );
      }

      return belongs;
    } catch (e) {
      Logger.error('OWNERSHIP: Check failed - $e');
      return false;
    }
  }

  // ============================================================================
  // PART 4: COMBINED PERMISSION CHECK
  // ============================================================================

  /// Check if user has permission for specific action
  /// WAJIB: Membership check + role-based permission
  /// Optional: Resource ownership verification
  Future<bool> hasPermission(
    String userId,
    String workshopId,
    String action, // 'create', 'edit', 'delete', 'assign', 'view', 'manage_staff'
  ) async {
    try {
      Logger.info(
        'PERMISSION: Checking - userId=$userId, workshopId=$workshopId, action=$action',
      );

      // STEP 1: Check membership (WAJIB)
      final isMember = await isMemberOfWorkshop(userId, workshopId);
      if (!isMember) {
        Logger.warning('PERMISSION: Access denied - not a member');
        return false;
      }

      // STEP 2: Check role (WAJIB)
      final role = await getUserRoleInWorkshop(userId, workshopId);
      if (role == null) {
        Logger.warning('PERMISSION: Access denied - no role');
        return false;
      }

      // STEP 3: Check role-based permissions
      final hasPermissionCheck = rolePermissions[role]?.contains(action) ?? false;

      if (hasPermissionCheck) {
        Logger.repository(
          'PERMISSION_CHECK',
          'action_allowed',
          {
            'user_id': userId,
            'workshop_id': workshopId,
            'role': role,
            'action': action,
            'result': 'allowed',
          },
        );
        Logger.success('PERMISSION: Granted - $role can perform $action');
      } else {
        Logger.warning(
          'PERMISSION: Denied - $role cannot perform $action',
        );
      }

      return hasPermissionCheck;
    } catch (e) {
      Logger.error('PERMISSION: Check failed - $e');
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

        final hasAccess = await hasPermission(userId, workshopId, action);
        results[resourceId] = hasAccess;
      }

      Logger.repository(
        'PERMISSION_CHECK',
        'batch_access',
        {'workshop_id': workshopId, 'results': results.length},
      );

      return results;
    } catch (e) {
      Logger.error('PERMISSION: Batch check failed - $e');
      return {};
    }
  }

  // ============================================================================
  // PART 5: UTILITY METHODS
  // ============================================================================

  /// Get all workshops user belongs to (by querying workshop_staff collection)
  Future<List<String>> getUserWorkshops(String userId) async {
    try {
      Logger.info('UTILITY: Getting workshops for user: $userId');

      if (userId.isEmpty) {
        Logger.error('UTILITY: Empty userId');
        return [];
      }

      final query = await _firestore
          .collection('workshop_staff')
          .where('user_id', isEqualTo: userId)
          .get();

      final workshops =
          query.docs.map((doc) => doc.get('workshop_id') as String).toList();

      Logger.repository(
        'UTILITY',
        'get_user_workshops',
        {'user_id': userId, 'count': workshops.length},
      );

      return workshops;
    } catch (e) {
      Logger.error('UTILITY: Workshop retrieval failed - $e');
      return [];
    }
  }

  /// Get user's primary workshop (owner's workshop first, then first available)
  Future<String?> getUserPrimaryWorkshop(String userId) async {
    try {
      Logger.info('UTILITY: Getting primary workshop for user: $userId');

      if (userId.isEmpty) {
        Logger.error('UTILITY: Empty userId');
        return null;
      }

      // Try to get owner workshop first
      final ownerQuery = await _firestore
          .collection('workshop_staff')
          .where('user_id', isEqualTo: userId)
          .where('role', isEqualTo: 'owner')
          .limit(1)
          .get();

      if (ownerQuery.docs.isNotEmpty) {
        final workshopId = ownerQuery.docs.first.get('workshop_id') as String;
        Logger.repository(
          'UTILITY',
          'primary_workshop',
          {'user_id': userId, 'workshop_id': workshopId, 'type': 'owner'},
        );
        return workshopId;
      }

      // Otherwise get first workshop
      final query = await _firestore
          .collection('workshop_staff')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final workshopId = query.docs.first.get('workshop_id') as String;
        Logger.repository(
          'UTILITY',
          'primary_workshop',
          {'user_id': userId, 'workshop_id': workshopId, 'type': 'first'},
        );
        return workshopId;
      }

      Logger.warning('UTILITY: No primary workshop found for user');
      return null;
    } catch (e) {
      Logger.error('UTILITY: Primary workshop retrieval failed - $e');
      return null;
    }
  }

  /// Get workshop staff count
  Future<int> getWorkshopStaffCount(String workshopId) async {
    try {
      Logger.info('UTILITY: Getting staff count for workshop: $workshopId');

      if (workshopId.isEmpty) {
        Logger.error('UTILITY: Empty workshopId');
        return 0;
      }

      final snapshot = await _firestore
          .collection('workshop_staff')
          .where('workshop_id', isEqualTo: workshopId)
          .count()
          .get();

      final count = snapshot.count ?? 0;

      Logger.repository(
        'UTILITY',
        'staff_count',
        {'workshop_id': workshopId, 'count': count},
      );

      return count;
    } catch (e) {
      Logger.error('UTILITY: Staff count retrieval failed - $e');
      return 0;
    }
  }

  /// Get all staff members for workshop with roles
  Future<Map<String, String>> getWorkshopStaffRoles(String workshopId) async {
    try {
      Logger.info(
        'UTILITY: Getting all staff roles for workshop: $workshopId',
      );

      if (workshopId.isEmpty) {
        Logger.error('UTILITY: Empty workshopId');
        return {};
      }

      final query = await _firestore
          .collection('workshop_staff')
          .where('workshop_id', isEqualTo: workshopId)
          .get();

      final staffRoles = <String, String>{};
      for (final doc in query.docs) {
        final userId = doc.get('user_id') as String?;
        final role = doc.get('role') as String?;
        if (userId != null && role != null) {
          staffRoles[userId] = role;
        }
      }

      Logger.repository(
        'UTILITY',
        'staff_roles',
        {'workshop_id': workshopId, 'count': staffRoles.length},
      );

      return staffRoles;
    } catch (e) {
      Logger.error('UTILITY: Staff roles retrieval failed - $e');
      return {};
    }
  }
}
