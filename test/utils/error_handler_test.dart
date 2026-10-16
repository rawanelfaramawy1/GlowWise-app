import 'package:flutter_test/flutter_test.dart';
import 'package:roowanglow/utils/error_handler.dart';
import 'dart:async';

void main() {
  group('AppError Tests', () {
    test('AppError should store message and optional parameters', () {
      final error = AppError(
        message: 'Test error',
        code: 'TEST_001',
        originalError: Exception('Original error'),
      );

      expect(error.message, 'Test error');
      expect(error.code, 'TEST_001');
      expect(error.originalError, isA<Exception>());
    });

    test('AppError should work with minimal parameters', () {
      final error = AppError(message: 'Simple error');

      expect(error.message, 'Simple error');
      expect(error.code, isNull);
      expect(error.originalError, isNull);
    });
  });

  group('ErrorHandler Tests', () {
    test('handleException should return AppError as is', () {
      final originalError = AppError(message: 'Test error');
      final handledError = ErrorHandler.handleException(originalError);

      expect(handledError, originalError);
    });

    test('handleException should handle FormatException', () {
      final formatException = FormatException('Invalid format');
      final handledError = ErrorHandler.handleException(formatException);

      expect(handledError.message, 'Invalid data format. Please try again.');
      expect(handledError.originalError, formatException);
    });

    test('handleException should handle TimeoutException', () {
      final timeoutException = TimeoutException('Request timed out');
      final handledError = ErrorHandler.handleException(timeoutException);

      expect(
        handledError.message,
        'Request timed out. Please check your connection and try again.',
      );
      expect(handledError.originalError, timeoutException);
    });

    test('handleException should handle unknown exceptions', () {
      final unknownException = Exception('Unknown error');
      final handledError = ErrorHandler.handleException(unknownException);

      expect(
        handledError.message,
        'An unexpected error occurred. Please try again.',
      );
      expect(handledError.originalError, unknownException);
    });
  });
}
