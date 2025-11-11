import 'package:equatable/equatable.dart';

/// Base class for all failures in the app
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Failures related to storage operations
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

/// Failures related to caching operations
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Failures related to validation
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Generic server failure
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}
