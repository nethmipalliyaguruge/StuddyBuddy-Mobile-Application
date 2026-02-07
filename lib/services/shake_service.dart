import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeService {
  static const double _shakeThreshold = 15.0;
  static const int _shakeCooldownMs = 2000;

  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime _lastShakeTime = DateTime.fromMillisecondsSinceEpoch(0);

  void startListening(void Function() onShake) {
    _subscription = accelerometerEventStream().listen((event) {
      final acceleration = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      // Subtract gravity (~9.8) and check if remaining force exceeds threshold
      if (acceleration > _shakeThreshold) {
        final now = DateTime.now();
        if (now.difference(_lastShakeTime).inMilliseconds > _shakeCooldownMs) {
          _lastShakeTime = now;
          onShake();
        }
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
