import '../models/landmark_data.dart';

class FrameBuffer {
  static const int maxFrames = 96;
  static const int sendInterval = 15;

  final List<FrameLandmarks> _buffer = [];
  int _frameCount = 0;

  int get frameCount => _frameCount;
  int get bufferSize => _buffer.length;
  bool get isFull => _buffer.length >= maxFrames;

  void add(FrameLandmarks landmarks) {
    _buffer.add(landmarks);
    _frameCount++;
    if (_buffer.length > maxFrames) {
      _buffer.removeAt(0);
    }
  }

  List<List<List<double>>>? getSequenceToSend() {
    if (_buffer.length < maxFrames) return null;
    if (_frameCount % sendInterval != 0) return null;
    return _buffer.map((frame) => frame.toNestedList()).toList();
  }

  void reset() {
    _buffer.clear();
    _frameCount = 0;
  }
}
