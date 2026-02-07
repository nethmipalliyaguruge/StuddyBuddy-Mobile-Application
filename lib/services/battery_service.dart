import 'package:battery_plus/battery_plus.dart';

class BatteryService {
  final Battery _battery = Battery();

  Future<int> getBatteryLevel() async {
    try {
      return await _battery.batteryLevel;
    } catch (e) {
      return -1;
    }
  }

  Future<BatteryState> getBatteryState() async {
    try {
      return await _battery.batteryState;
    } catch (e) {
      return BatteryState.unknown;
    }
  }

  Future<bool> isCharging() async {
    try {
      final state = await getBatteryState();
      return state == BatteryState.charging || state == BatteryState.full;
    } catch (e) {
      return false;
    }
  }

  Future<bool> canPerformHeavyTask({int minBatteryLevel = 20}) async {
    final info = await getBatteryInfo();
    if (info.isCharging) return true;
    return info.level >= minBatteryLevel;
  }

  Future<BatteryInfo> getBatteryInfo() async {
    try {
      final level = await getBatteryLevel();
      final state = await getBatteryState();
      return BatteryInfo(level: level, state: state);
    } catch (e) {
      return BatteryInfo(level: -1, state: BatteryState.unknown);
    }
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
        return 'Unknown';
    }
  }
}
