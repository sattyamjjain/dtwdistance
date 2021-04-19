import 'package:dtwdistance/dtwdistance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test to measure distance of two arrays', () {
    final dtwObject = DTW();
    expect(
        dtwObject.distance([0, 1, 2, 3, 4], [0, 2, 4, 6, 8]), 4.69041575982343);
    expect(
        dtwObject.distance([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            [0, 2, 4, 6, 8, 12, 14, 16, 18, 20]),
        15.0);
    expect(
        dtwObject
            .distance([0, 0, 1, 2, 1, 0, 1, 0, 0], [0, 1, 2, 0, 0, 0, 0, 0, 0]),
        1.4142135623730951);
  });
}
