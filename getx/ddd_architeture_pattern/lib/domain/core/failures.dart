import 'package:equatable/equatable.dart';

/// Base Failure class for domain errors
///
/// In DDD, failures represent domain-level errors.
/// They are part of the ubiquitous language.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Failure when storage operations fail
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

/// Failure when validation fails
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Failure when entity not found
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Failure for unexpected errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
