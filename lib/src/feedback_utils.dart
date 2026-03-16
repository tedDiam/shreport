import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';

/// Wraps an [OnFeedbackCallback] to show a loading dialog while the async
/// work is in progress, then dismisses it when done.
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
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  };
}
