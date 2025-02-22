import 'package:feedback/feedback.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shake_detector/shake_detector.dart';
import 'package:shreport/src/issue_tracker_config.dart';
import 'package:shreport/src/shreport_jira.dart';

class ShakeFeedback extends StatefulWidget {
  final Widget child;
  final IssueTrackerConfig issueTrackerConfig;

  const ShakeFeedback({Key? key, required this.child, required this.issueTrackerConfig}) : super(key: key);

  @override
  _ShreportFeedbackState createState() => _ShreportFeedbackState();
}

class _ShreportFeedbackState extends State<ShakeFeedback> {
  late ShakeDetector _detector;

  @override
  void initState() {
    super.initState();
    _detector = ShakeDetector.autoStart(
      onShake: () {
        switch (widget.issueTrackerConfig.runtimeType) {
          case JiraIssueTracker:
            BetterFeedback.of(context).showAndUploadToJira(
              issueTracker: widget.issueTrackerConfig as JiraIssueTracker,
            );
            break;
          case GitlabIssueTracker:
            // Add other cases here if needed
            break;
          case AsanaIssueTracker:
            break;
          // Add other cases here if needed
        }
      },
    );
  }

  @override
  void dispose() {
    _detector.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
