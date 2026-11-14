/// Generation of the offline cache, bumped when it is wiped.
///
/// A write prepared before a wipe (a response from the old server still in
/// flight when the server changed) captures the epoch before its request and
/// is dropped if the epoch moved meanwhile.
class CacheEpoch {
  int _value = 0;

  int get value => _value;

  void bump() => _value++;
}
