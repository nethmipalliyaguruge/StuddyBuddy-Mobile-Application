import 'package:flutter/foundation.dart';
import '../services/connectivity_service.dart';

class ConnectivityProvider with ChangeNotifier {
  final ConnectivityService _connectivityService;

  bool _isOnline = true;
  bool _isInitialized = false;

  ConnectivityProvider(this._connectivityService);

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _isOnline = await _connectivityService.checkConnectivity();
    _isInitialized = true;

    _connectivityService.startListening((isOnline) {
      if (_isOnline != isOnline) {
        _isOnline = isOnline;
        notifyListeners();
      }
    });

    notifyListeners();
  }

  Future<bool> checkConnectivity() async {
    _isOnline = await _connectivityService.checkConnectivity();
    notifyListeners();
    return _isOnline;
  }

  void dispose() {
    _connectivityService.dispose();
  }
}
