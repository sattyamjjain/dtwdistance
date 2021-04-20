library dtwdistance;

import 'dart:math';

import 'package:dtwdistance/ed.dart';
import 'package:logger/logger.dart';

var dtwCC;
var logger = Logger();

class DTW {
  double ubEuclidean(s1, s2) {
    return ED().edDistance(s1, s2);
  }

  double distance(List<double> s1, List<double> s2,
      {window,
      maxDist,
      maxStep,
      maxLengthDiff,
      penalty,
      psi,
      useC = false,
      usePruning = false,
      onlyUb = false}) {
    /*
    Dynamic Time Warping.
    This function keeps a compact matrix, not the full warping paths matrix.
    :param s1: First sequence
    :param s2: Second sequence
    :param window: Only allow for maximal shifts from the two diagonals smaller than this number.
        It includes the diagonal, meaning that an Euclidean distance is obtained by setting window=1.
    :param maxDist: Stop if the returned values will be larger than this value
    :param maxStep: Do not allow steps larger than this value
    :param maxLengthDiff: Return infinity if length of two series is larger
    :param penalty: Penalty to add if compression or expansion is applied
    :param psi: Psi relaxation parameter (ignore start and end of matching).
        Useful for cyclical series.
    :param useC: Use fast pure c compiled functions
    :param usePruning: Prune values based on Euclidean distance.
        This is the same as passing ub_euclidean() to max_dist
    :param onlyUb: Only compute the upper bound (Euclidean).
    Returns: DTW distance
    */

    var inf = "inf";

    if (useC) {
      if (dtwCC == null) {
        logger.e("C-library not available, using the Python version");
      } else {
        logger.d('distance fast');
      }
    }

    var r = s1.length;
    var c = s2.length;

    if (maxLengthDiff != null && (r - c).abs() > maxLengthDiff) {
      print('inside if');
      // return inf;
    }

    if (window == null) {
      window = max(r, c);
    }

    if (maxStep == null) {
      maxStep = inf;
    } else {
      maxStep *= maxStep;
    }

    if (usePruning || onlyUb) {
      maxDist = pow(ubEuclidean(s1, s2), 2);
      if (onlyUb) {
        return maxDist;
      }
    } else if (maxDist == null) {
      maxDist = inf;
    } else {
      maxDist *= maxDist;
    }

    if (penalty == null) {
      penalty = 0;
    } else {
      penalty *= penalty;
    }

    if (psi == null) {
      psi = 0;
    }

    var length = min(c + 1, (r - c).abs() + 2 * (window - 1) + 1 + 1 + 1);

    List dtw = ['d'];
    for (int i = 0; i < 2 * length - 1; i++) {
      dtw.add(inf);
    }

    var sc = 0;
    var ec = 0;
    var ecNext = 0;
    var smallerFound = false;

    for (int i = 0; i < psi + 1; i++) {
      dtw[i] = 0.0;
    }

    var skip = 0;
    var i0 = 1;
    var i1 = 0;
    var psiShortest = inf;
    var d;

    for (int i = 0; i < r; i++) {
      var skipp = skip;
      skip = max(0, i - max(0, r - c) - window + 1);
      i0 = 1 - i0;
      i1 = 1 - i1;
      for (int ii = i1 * length; ii < i1 * length + length; ii++) {
        dtw[ii] = inf;
      }
      var jStart = max(0, i - max(0, r - c) - window + 1);
      var jEnd = min(c, i + max(0, c - r) + window);

      if (sc > jStart) {
        jStart = sc;
      }
      smallerFound = false;
      ecNext = i;

      if (length == c + 1) {
        skip = 0;
      }
      if (psi != 0 && jStart == 0 && i < psi) {
        dtw[i1 * length] = 0;
      }
      for (int j = jStart; j < jEnd; j++) {
        d = pow((s1[i] - s2[j]), 2);
        if (maxDist.runtimeType != String) {
          if (d > maxStep) {
            continue;
          }
        }
        assert(j + 1 - skip >= 0);
        assert(j - skipp >= 0);
        assert(j + 1 - skipp >= 0);
        assert(j - skip >= 0);

        var num1 = dtw[i0 * length + j - skipp];
        var num2;
        if (dtw[i0 * length + j + 1 - skipp].runtimeType != String) {
          num2 = dtw[i0 * length + j + 1 - skipp] + penalty;
        } else {
          num2 = dtw[i0 * length + j + 1 - skipp];
        }
        var num3;
        if (dtw[i1 * length + j - skipp].runtimeType != String) {
          num3 = dtw[i1 * length + j - skipp] + penalty;
        } else {
          num3 = dtw[i1 * length + j - skipp];
        }

        List<double> tempList = [];

        if (num1.runtimeType != String) {
          tempList.add(num1);
        }
        if (num2.runtimeType != String) {
          tempList.add(num2);
        }
        if (num3.runtimeType != String) {
          tempList.add(num3);
        }

        dtw[i1 * length + j + 1 - skip] = d + tempList.reduce(min);

        if (maxDist.runtimeType != String) {
          if (dtw[i1 * length + j + 1 - skip] > maxDist) {
            if (!smallerFound) {
              sc = j + 1;
            }
            if (j >= ec) {
              break;
            }
          } else {
            smallerFound = true;
            ecNext = j + 1;
          }
        }
      }
      ec = ecNext;
      if (psi != 0 && jEnd == s2.length && s1.length - 1 - i <= psi) {
        psiShortest = min(psiShortest, dtw[i1 * length + length - 1]);
      }
    }
    if (psi == 0) {
      d = dtw[i1 * length + min(c, c + window - 1) - skip];
    }
    if (maxDist.runtimeType != String) {
      if (maxDist != null && d > maxDist) {
        d = inf;
      }
    }
    d = sqrt(d);
    return d;
  }
}
