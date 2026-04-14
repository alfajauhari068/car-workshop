import 'package:car_workshop/features/auth/data/datasources/user_remote_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/services/auth_service.dart';
import '../models/user_model.dart';

class FirebaseAuthDataSource implements UserRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore fireStore;
  final AuthService authService;

  FirebaseAuthDataSource(this.firebaseAuth, this.fireStore, this.authService);

  @override
  Future<Either<Failure, UserModel>> registerUser(
      String email, String password, String name, UserRole role) async {
    try {
      // Validate email and password
      if (email.isEmpty || password.isEmpty) {
        return const Left(ServerFailure('Email and password cannot be empty.'));
      }
      if (password.length < 6) {
        return const Left(ServerFailure('Password must be at least 6 characters.'));
      }

      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email.toLowerCase().trim(),
        password: password,
      );

      if (userCredential.user != null) {
        final userModel = UserModel(
          id: userCredential.user!.uid,
          email: email.toLowerCase().trim(),
          name: name,
          role: role,
        );

        // Save user data to Firestore
        await fireStore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toJson());

        authService.setCurrentUser(userModel);
        return Right(userModel);
      } else {
        return const Left(ServerFailure('User creation failed.'));
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error (Register): ${e.code} - ${e.message}');
      return Left(
          ServerFailure(e.message ?? 'An error occurred during registration.'));
    } catch (error) {
      print('Error (Register): $error');
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> loginUser(
      String email, String password) async {
    try {
      // Normalize email (lowercase and trim)
      final normalizedEmail = email.toLowerCase().trim();
      
      if (normalizedEmail.isEmpty || password.isEmpty) {
        return const Left(ServerFailure('Email and password cannot be empty.'));
      }

      print('Attempting login with email: $normalizedEmail');
      
      UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      if (userCredential.user != null) {
        final userDoc = await fireStore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          final userModel = UserModel.fromJson(userDoc.data()!);
          authService.setCurrentUser(userModel);
          return Right(userModel);
        } else {
          // If user document doesn't exist, create it
          print('User document not found, creating new document');
          final userModel = UserModel(
            id: userCredential.user!.uid,
            email: normalizedEmail,
            name: userCredential.user!.displayName ?? 'User',
            role: UserRole.mechanic,
          );
          
          await fireStore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userModel.toJson());
              
          authService.setCurrentUser(userModel);
          return Right(userModel);
        }
      } else {
        return const Left(ServerFailure('Login failed. Please try again.'));
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error (Login): ${e.code} - ${e.message}');
      return Left(
          ServerFailure(e.message ?? 'An error occurred during login.'));
    } catch (error) {
      print('Error (Login): $error');
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logoutUser() async {
    try {
      await firebaseAuth.signOut();
      authService.clearCurrentUser();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(
          ServerFailure(e.message ?? 'An error occurred during logout.'));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserModel>>> getAllMechanics() async {
    try {
      QuerySnapshot querySnapshot = await fireStore
          .collection('users')
          .where('role', isEqualTo: UserRole.mechanic.name)
          .get();

      List<UserModel> mechanics = querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return Right(mechanics);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getUserById(String id) async {
    try {
      return Right(
          UserModel(id: id, email: '', name: '', role: UserRole.mechanic));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createUser(UserModel user) async {
    try {
      await fireStore.collection('users').doc(user.id).set(user.toJson());
      return const Right(null);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }
}
