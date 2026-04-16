import 'package:flutter/foundation.dart';

const _kApiBaseUrlOverride = String.fromEnvironment('API_BASE_URL', defaultValue: '');

String apiBaseUrl() {
  if (_kApiBaseUrlOverride.isNotEmpty) return _kApiBaseUrlOverride;
  // Web runs on the same machine: localhost works.
  if (kIsWeb) return 'http://localhost:5000';
  // Android emulator needs 10.0.2.2 to reach host machine.
  return 'http://10.0.2.2:5000';
}
