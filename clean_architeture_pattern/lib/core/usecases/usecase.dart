import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base class for all use cases
/// Takes a parameter of type [Params] and returns Either<Failure, Type>
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Used when a use case doesn't need parameters
class NoParams {
  const NoParams();
}
