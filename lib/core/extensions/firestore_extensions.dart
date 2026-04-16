import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:car_workshop/core/errors/failure.dart';
import 'package:car_workshop/core/utils/logger_util.dart';

/// Extended Firestore helper for transaction and batch operations
extension FirestoreTransaction on FirebaseFirestore {
  /// Execute atomic transaction - all or nothing
  /// Use this when you need multiple writes to succeed together
  /// Example: Create workshop + add owner to staff
  Future<Either<Failure, T>> runAtomicTransaction<T>(
    Future<T> Function(Transaction) operation,
    String operationName,
  ) async {
    try {
      Logger.info('Starting atomic transaction: $operationName');
      
      final result = await runTransaction<T>((transaction) async {
        return await operation(transaction);
      });
      
      Logger.success('Transaction succeeded: $operationName');
      return Right(result);
    } on FirebaseException catch (e) {
      Logger.error(
        'Transaction failed: $operationName',
        'Code: ${e.code}, Message: ${e.message}',
      );
      return Left(ServerFailure(e.message ?? 'Transaction failed'));
    } catch (e) {
      Logger.error(
        'Unknown transaction error: $operationName',
        e.toString(),
      );
      return Left(ServerFailure('Transaction error: $e'));
    }
  }

  /// Write single document with error handling
  Future<Either<Failure, void>> writeDocument({
    required FirebaseFirestore firestore,
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    try {
      Logger.repository('WRITE', collection, data);
      
      await firestore.collection(collection).doc(docId).set(data, SetOptions(merge: merge));
      
      Logger.success('Document written: $collection/$docId');
      return const Right(null);
    } on FirebaseException catch (e) {
      Logger.error('Write failed: $collection/$docId', e.message);
      return Left(ServerFailure(e.message ?? 'Write failed'));
    } catch (e) {
      Logger.error('Unknown write error: $collection/$docId', e.toString());
      return Left(ServerFailure('Write error: $e'));
    }
  }

  /// Read single document with error handling
  Future<Either<Failure, DocumentSnapshot>> readDocument({
    required FirebaseFirestore firestore,
    required String collection,
    required String docId,
  }) async {
    try {
      Logger.repository('READ', collection, null);
      
      final doc = await firestore.collection(collection).doc(docId).get();
      
      if (!doc.exists) {
        Logger.warning('Document not found: $collection/$docId');
        return const Left(NotFoundFailure('Document not found'));
      }
      
      Logger.success('Document read: $collection/$docId');
      return Right(doc);
    } on FirebaseException catch (e) {
      Logger.error('Read failed: $collection/$docId', e.message);
      return Left(ServerFailure(e.message ?? 'Read failed'));
    } catch (e) {
      Logger.error('Unknown read error: $collection/$docId', e.toString());
      return Left(ServerFailure('Read error: $e'));
    }
  }

  /// Query documents with error handling
  Future<Either<Failure, QuerySnapshot>> queryDocuments({
    required FirebaseFirestore firestore,
    required String collection,
    required String field,
    required dynamic value,
  }) async {
    try {
      Logger.repository('QUERY', collection, {field: value});
      
      final query = firestore.collection(collection).where(field, isEqualTo: value);
      final result = await query.get();
      
      Logger.success('Query succeeded: $collection where $field == $value');
      return Right(result);
    } on FirebaseException catch (e) {
      Logger.error('Query failed: $collection', e.message);
      return Left(ServerFailure(e.message ?? 'Query failed'));
    } catch (e) {
      Logger.error('Unknown query error: $collection', e.toString());
      return Left(ServerFailure('Query error: $e'));
    }
  }

  /// Delete document with error handling
  Future<Either<Failure, void>> deleteDocument({
    required FirebaseFirestore firestore,
    required String collection,
    required String docId,
  }) async {
    try {
      Logger.repository('DELETE', collection, {docId: 'DELETED'});
      
      await firestore.collection(collection).doc(docId).delete();
      
      Logger.success('Document deleted: $collection/$docId');
      return const Right(null);
    } on FirebaseException catch (e) {
      Logger.error('Delete failed: $collection/$docId', e.message);
      return Left(ServerFailure(e.message ?? 'Delete failed'));
    } catch (e) {
      Logger.error('Unknown delete error: $collection/$docId', e.toString());
      return Left(ServerFailure('Delete error: $e'));
    }
  }

  /// Update document with error handling
  Future<Either<Failure, void>> updateDocument({
    required FirebaseFirestore firestore,
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      Logger.repository('UPDATE', collection, data);
      
      await firestore.collection(collection).doc(docId).update(data);
      
      Logger.success('Document updated: $collection/$docId');
      return const Right(null);
    } on FirebaseException catch (e) {
      Logger.error('Update failed: $collection/$docId', e.message);
      return Left(ServerFailure(e.message ?? 'Update failed'));
    } catch (e) {
      Logger.error('Unknown update error: $collection/$docId', e.toString());
      return Left(ServerFailure('Update error: $e'));
    }
  }
}
