import 'dart:math';

class KNN {
  final int k;
  late List<List<double>> data;

  KNN({required this.k});

  // Fit the model with the given data
  void fit(List<List<double>> data) {
    this.data = data;
  }

  // Predict the nearest neighbors for the given points
  List<int> predict(List<List<double>> points) {
    return points.map((point) {
      final distances = data
          .asMap()
          .map((index, row) => MapEntry(index, _euclideanDistance(row, point)))
          .entries
          .toList();

      distances.sort((a, b) => a.value.compareTo(b.value));
      return distances.take(k).map((entry) => entry.key).toList().first;
    }).toList();
  }

  // Calculate the Euclidean distance between two points
  double _euclideanDistance(List<double> point1, List<double> point2) {
    double sum = 0;
    for (int i = 0; i < point1.length; i++) {
      sum += (point1[i] - point2[i]) * (point1[i] - point2[i]);
    }
    return sqrt(sum); // Use sqrt from dart:math
  }
}