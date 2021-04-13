import 'dart:math';

class ED {
  double edDistance(List<double> s1, List<double> s2) {
    /* Euclidean distance between two sequences. Supports different lengths.
    If the two series differ in length, compare the last element of the shortest series
    to the remaining elements in the longer series. This is compatible with Euclidean
    distance being used as an upper bound for DTW.
    :param s1: Sequence of numbers
    :param s2: Sequence of numbers
    :return: Euclidean distance
    */
    var n = min(s1.length, s2.length);
    var ub = 0;

    //for

    if (s1.length > s2.length) {
      var v2 = s2[n - 1];
      for (var v1 in s1[n:]) {
        ub += pow((v1 - v2), 2);
      }
    } else if (s1.length < s2.length) {
      var v1 = s1[n - 1];
      for (var v2 in s2[n:]) {
        ub += pow((v1 - v2), 2);
      }
    }

    return sqrt(ub);
  }
}
