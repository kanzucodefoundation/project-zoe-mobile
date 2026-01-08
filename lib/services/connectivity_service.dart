import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service to monitor network connectivity status
class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  /// Initialize the connectivity service
  Future<void> initialize() async {
    // Check initial connectivity status
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
    
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  /// Update connection status based on connectivity result
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // User is online if any connection type is available (wifi, mobile, etc.)
    final wasOnline = _isOnline;
    _isOnline = results.any((result) => 
      result == ConnectivityResult.wifi || 
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.ethernet ||
      result == ConnectivityResult.vpn
    );
    
    // Only notify listeners if status actually changed
    if (wasOnline != _isOnline) {
      debugPrint('🌐 Connectivity changed: ${_isOnline ? "Online" : "Offline"}');
      notifyListeners();
    }
  }

  /// Clean up resources
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}