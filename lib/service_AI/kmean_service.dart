import 'dart:math';
import 'package:ml_linalg/linalg.dart';

class KMeans {
  final int k; // Số lượng cụm
  List<List<double>> centroids = []; // Tâm cụm

  KMeans({required this.k});

  // Khởi tạo centroids ngẫu nhiên từ các điểm dữ liệu
  void _initializeCentroids(Matrix data) {
    final random = Random();
    centroids = [];
    for (int i = 0; i < k; i++) {
      final randomIndex = random.nextInt(data.rowsNum);
      centroids.add(data.getRow(randomIndex).toList());
    }
  }

  // Tính khoảng cách Euclidean giữa hai điểm
  double _euclideanDistance(List<double> point1, List<double> point2) {
    double sum = 0;
    for (int i = 0; i < point1.length; i++) {
      sum += pow(point1[i] - point2[i], 2);
    }
    return sqrt(sum);
  }

  // Dự đoán cụm cho các điểm dữ liệu
  List<int> predict(Matrix data) {
    List<int> labels = List.filled(data.rowsNum, -1);
    bool converged = false;

    while (!converged) {
      converged = true;
      // Tạo danh sách các điểm dữ liệu cho mỗi cụm
      List<List<List<double>>> clusters = List.generate(k, (_) => []);

      for (int i = 0; i < data.rowsNum; i++) {
        List<double> point = data.getRow(i).toList();
        int closestCentroid = _findClosestCentroid(point);
        if (labels[i] != closestCentroid) {
          converged = false;
          labels[i] = closestCentroid;
        }
        clusters[closestCentroid].add(point);
      }

      // Cập nhật centroids mới
      for (int i = 0; i < k; i++) {
        if (clusters[i].isNotEmpty) {
          centroids[i] = _computeCentroid(clusters[i]);
        }
      }
    }
    return labels;
  }

  // Tìm centroid gần nhất với điểm
  int _findClosestCentroid(List<double> point) {
    double minDistance = double.infinity;
    int closestCentroid = 0;

    for (int i = 0; i < k; i++) {
      double distance = _euclideanDistance(point, centroids[i]);
      if (distance < minDistance) {
        minDistance = distance;
        closestCentroid = i;
      }
    }
    return closestCentroid;
  }

  // Tính centroid của một nhóm điểm
  List<double> _computeCentroid(List<List<double>> cluster) {
    List<double> centroid = List.filled(cluster[0].length, 0);
    for (var point in cluster) {
      for (int i = 0; i < point.length; i++) {
        centroid[i] += point[i];
      }
    }
    return centroid.map((e) => e / cluster.length).toList();
  }

  // Fit mô hình KMeans với dữ liệu
  void fit(Matrix data) {
    _initializeCentroids(data);
    predict(data);
  }
}
