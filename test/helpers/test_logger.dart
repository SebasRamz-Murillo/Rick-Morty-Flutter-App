import 'dart:convert';

/// Helper para logging detallado en tests.
class TestLogger {
  static void logTestData(String testName, Map<String, dynamic> data) {
    print('\n${'=' * 60}');
    print('TEST: $testName');
    print('-' * 60);
    data.forEach((key, value) {
      if (value is Map || value is List) {
        print('$key:');
        print(_prettyJson(value));
      } else {
        print('$key: $value');
      }
    });
    print('=' * 60);
  }

  static void logInput(String label, dynamic value) {
    print('  INPUT [$label]: ${_format(value)}');
  }

  static void logOutput(String label, dynamic value) {
    print('  OUTPUT [$label]: ${_format(value)}');
  }

  static void logExpected(String label, dynamic value) {
    print('  EXPECTED [$label]: ${_format(value)}');
  }

  static String _format(dynamic value) {
    if (value is Map || value is List) {
      return _prettyJson(value);
    }
    return value.toString();
  }

  static String _prettyJson(dynamic obj) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(obj);
  }
}
