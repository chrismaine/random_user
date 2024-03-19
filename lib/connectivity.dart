import 'package:connectivity/connectivity.dart';

class ConnectivityService {
  static Future<bool> isConnected() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  static Stream<bool> subscribeToConnectivityChanges() {
    try {
      return Connectivity().onConnectivityChanged.map((result) => result != ConnectivityResult.none);
    } catch (e) {
      print('Error subscribing to connectivity changes: $e');
      return Stream.value(false);
    }
  }
}
