import 'package:flutter/material.dart';
import 'dart:async';

class AppError {
  final String message;
  final String? code;
  final dynamic originalError;

  AppError({required this.message, this.code, this.originalError});
}

class ErrorHandler {
  static void showError(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showErrorDialog(BuildContext context, AppError error) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(error.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  static AppError handleException(dynamic error) {
    if (error is AppError) {
      return error;
    }

    // Handle specific types of errors
    if (error is FormatException) {
      return AppError(
        message: 'Invalid data format. Please try again.',
        originalError: error,
      );
    }

    if (error is TimeoutException) {
      return AppError(
        message:
            'Request timed out. Please check your connection and try again.',
        originalError: error,
      );
    }

    // Default error message
    return AppError(
      message: 'An unexpected error occurred. Please try again.',
      originalError: error,
    );
  }
}
