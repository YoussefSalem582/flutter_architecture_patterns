import 'package:equatable/equatable.dart';

/// NoteTimestamp - Value Object for Note Creation Time
///
/// Encapsulates timestamp logic and formatting.
/// Ensures timestamp immutability and provides useful operations.
class NoteTimestamp extends Equatable {
  final DateTime dateTime;

  const NoteTimestamp._(this.dateTime);

  /// Create timestamp from DateTime
  factory NoteTimestamp(DateTime dateTime) {
    return NoteTimestamp._(dateTime);
  }

  /// Create timestamp for current moment
  factory NoteTimestamp.now() {
    return NoteTimestamp._(DateTime.now());
  }

  /// Create timestamp from ISO 8601 string
  factory NoteTimestamp.fromIso8601(String iso) {
    return NoteTimestamp._(DateTime.parse(iso));
  }

  /// Convert to ISO 8601 string
  String toIso8601() => dateTime.toIso8601String();

  /// Check if timestamp is in the past
  bool get isPast => dateTime.isBefore(DateTime.now());

  /// Check if timestamp is today
  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  @override
  List<Object?> get props => [dateTime];

  @override
  String toString() => 'NoteTimestamp(${dateTime.toIso8601String()})';
}
