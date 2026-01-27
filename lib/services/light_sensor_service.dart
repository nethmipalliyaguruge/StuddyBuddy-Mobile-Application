import 'dart:async';
import 'package:light/light.dart';

class LightSensorService {
  final Light _light = Light();
  StreamSubscription<int>? _subscription;
  int _currentLux = -1;

  int get currentLux => _currentLux;

  bool get isLowLight => _currentLux >= 0 && _currentLux < 50;
  bool get isMediumLight => _currentLux >= 50 && _currentLux < 200;
  bool get isBrightLight => _currentLux >= 200;

  Stream<int> get luxStream => _light.lightSensorStream;

  void startListening(Function(int lux) onLuxChange) {
    _subscription = _light.lightSensorStream.listen((lux) {
      _currentLux = lux;
      onLuxChange(lux);
    }, onError: (error) {
      _currentLux = -1;
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    stopListening();
  }

  String getLightCondition() {
    if (_currentLux < 0) return 'Unknown';
    if (_currentLux < 50) return 'Low light';
    if (_currentLux < 200) return 'Normal light';
    if (_currentLux < 1000) return 'Bright light';
    return 'Very bright';
  }

  bool shouldSuggestDarkMode() {
    return _currentLux >= 0 && _currentLux < 50;
  }
}
