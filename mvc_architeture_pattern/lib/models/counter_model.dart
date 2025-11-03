/// Model class for Counter
/// Holds the counter value data
class CounterModel {
  int value;

  CounterModel({this.value = 0});

  /// Increment the counter value
  void increment() {
    value++;
  }

  /// Decrement the counter value
  void decrement() {
    value--;
  }

  /// Reset the counter to zero
  void reset() {
    value = 0;
  }
}
