import 'package:equatable/equatable.dart';

/// Base Failure class for error handling
/// All failures extend this class for type-safe error handling
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Storage-related failures (read/write errors)
class StorageFailure extends Failure {
  const StorageFailure([String message = 'Storage operation failed'])
    : super(message);
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache operation failed'])
    : super(message);
}

/// Validation failures (business rules violation)
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation failed'])
    : super(message);
}

/// Server-related failures (for future API integration)
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred'])
    : super(message);
}

/// Unexpected failures
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([String message = 'An unexpected error occurred'])
    : super(message);
}
