class LandmarkPoint {
  final double x;
  final double y;
  final double z;

  const LandmarkPoint({required this.x, required this.y, this.z = 0.0});

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'z': z};

  List<double> toList() => [x, y, z];

  factory LandmarkPoint.fromList(List<double> vals) {
    return LandmarkPoint(
      x: vals[0],
      y: vals[1],
      z: vals.length > 2 ? vals[2] : 0.0,
    );
  }
}

class FrameLandmarks {
  final List<LandmarkPoint> pose;       // 7 landmarks
  final List<LandmarkPoint> leftHand;   // 10 landmarks
  final List<LandmarkPoint> rightHand;  // 10 landmarks

  const FrameLandmarks({
    required this.pose,
    required this.leftHand,
    required this.rightHand,
  });

  int get totalLandmarks => pose.length + leftHand.length + rightHand.length;

  List<List<double>> toNestedList() {
    final result = <List<double>>[];
    for (final p in pose) result.add(p.toList());
    for (final p in leftHand) result.add(p.toList());
    for (final p in rightHand) result.add(p.toList());
    return result;
  }

  factory FrameLandmarks.empty() {
    const zero = LandmarkPoint(x: 0, y: 0, z: 0);
    return FrameLandmarks(
      pose: List.filled(7, zero),
      leftHand: List.filled(10, zero),
      rightHand: List.filled(10, zero),
    );
  }
}
