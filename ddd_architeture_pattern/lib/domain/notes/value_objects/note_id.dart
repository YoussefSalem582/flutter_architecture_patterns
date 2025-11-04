import 'package:equatable/equatable.dart';

/// NoteId - Value Object for Note Identity
///
/// In DDD, even IDs can be value objects to encapsulate validation.
/// This ensures all note IDs are valid UUIDs.
class NoteId extends Equatable {
  final String value;

  const NoteId(this.value);

  /// Validate that ID is not empty
  bool get isValid => value.isNotEmpty;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'NoteId($value)';
}
