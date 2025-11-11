import 'package:equatable/equatable.dart';

/// NoteTimestamp - Value Object for Note Creation Time
///
/// In DDD, wrapping DateTime in a value object:
/// - Provides clear domain meaning
/// - Centralizes formatting and comparison logic
/// - Makes the domain model more expressive
class NoteTimestamp extends Equatable {
  final DateTime dateTime;

  const NoteTimestamp._(this.dateTime);

  /// Create timestamp for now
  factory NoteTimestamp.now() {
    return NoteTimestamp._(DateTime.now());
  }

  /// Create from DateTime
  factory NoteTimestamp.from(DateTime dateTime) {
    return NoteTimestamp._(dateTime);
  }

  /// Format for display
  String get formatted {
    return '${dateTime.year}-${_pad(dateTime.month)}-${_pad(dateTime.day)} '
        '${_pad(dateTime.hour)}:${_pad(dateTime.minute)}';
  }

  /// Get relative time (e.g., "2 minutes ago")
  String get relative {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return formatted;
    }
  }

  /// Helper to pad numbers
  String _pad(int number) => number.toString().padLeft(2, '0');

  @override
  List<Object?> get props => [dateTime];

  @override
  String toString() => 'NoteTimestamp($formatted)';
}
