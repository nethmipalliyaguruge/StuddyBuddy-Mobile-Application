import 'package:battery_plus/battery_plus.dart';

class BatteryService {
  final Battery _battery = Battery();

  Future<int> getBatteryLevel() async {
    return await _battery.batteryLevel;
  }

  Future<BatteryState> getBatteryState() async {
    return await _battery.batteryState;
  }

  Future<bool> isCharging() async {
    final state = await getBatteryState();
    return state == BatteryState.charging || state == BatteryState.full;
  }

  Future<bool> canPerformHeavyTask({int minBatteryLevel = 20}) async {
    final level = await getBatteryLevel();
    final charging = await isCharging();

    if (charging) return true;
    return level >= minBatteryLevel;
  }

  Future<BatteryInfo> getBatteryInfo() async {
    final level = await getBatteryLevel();
    final state = await getBatteryState();
    return BatteryInfo(level: level, state: state);
  }

  Stream<BatteryState> get onBatteryStateChanged {
    return _battery.onBatteryStateChanged;
  }
}

class BatteryInfo {
  final int level;
  final BatteryState state;

  BatteryInfo({required this.level, required this.state});

  bool get isLow => level < 20;
  bool get isCharging => state == BatteryState.charging || state == BatteryState.full;

  String get stateString {
    switch (state) {
      case BatteryState.charging:
        return 'Charging';
      case BatteryState.discharging:
        return 'Discharging';
      case BatteryState.full:
        return 'Full';
      case BatteryState.connectedNotCharging:
        return 'Connected (not charging)';
      case BatteryState.unknown:
      default:
        return 'Unknown';
    }
  }
}
