import 'package:dartz/dartz.dart';

import '../errors/failure.dart';

abstract class UseCase<R, Params> {
  Future<Either<Failure, R>> call(Params params);
}
