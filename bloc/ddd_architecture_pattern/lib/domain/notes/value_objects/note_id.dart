import 'package:equatable/equatable.dart';

/// NoteId - Value Object for Note Identity
///
/// In DDD, even IDs can be value objects to encapsulate:
/// - Validation rules
/// - Identity comparison logic
/// - Type safety
class NoteId extends Equatable {
  final String value;

  const NoteId._(this.value);

  /// Factory with validation
  factory NoteId(String id) {
    if (id.isEmpty) {
      throw ArgumentError('Note ID cannot be empty');
    }
    return NoteId._(id);
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'NoteId($value)';
}
