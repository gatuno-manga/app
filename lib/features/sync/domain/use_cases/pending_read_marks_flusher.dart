import '../../../users/domain/value_objects/user_id.dart';

/// Flushes queued offline chapter-read marks for a signed-in user.
abstract class PendingReadMarksFlusher {
  Future<void> flushPending(UserId userId);
}
