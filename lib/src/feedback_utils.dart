import 'dart:io';

import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';

/// Wraps an [OnFeedbackCallback] to show a loading dialog while the async
/// work is in progress, dismiss it when done, and show a SnackBar on error.
OnFeedbackCallback withLoadingDialog(
  BuildContext context,
  OnFeedbackCallback callback,
) {
  return (UserFeedback feedback) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
    try {
      await callback(feedback);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage(e)),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  };
}

String _errorMessage(Object error) {
  if (error is SocketException) {
    return 'No internet connection. Please check your network and try again.';
  }
  if (error is HttpException) {
    final msg = error.message;
    if (msg.contains('401')) return 'Authentication failed. Check your API credentials.';
    if (msg.contains('403')) return 'Access denied. Check your API permissions.';
    if (msg.contains('404')) return 'Resource not found. Check your project configuration.';
    if (msg.contains('5')) return 'Server error. Please try again later.';
    return 'Request failed. Please try again.';
  }
  return 'Failed to submit report. Please try again.';
}
