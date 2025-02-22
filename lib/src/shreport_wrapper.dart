import 'package:feedback/feedback.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shreport/src/issue_tracker_config.dart';
import 'package:shreport/src/shake_feedback.dart';

class ShreportWrapper extends StatelessWidget {
  final Widget child;
  final IssueTrackerConfig issueTrackerConfig;

  const ShreportWrapper({Key? key, required this.child, required this.issueTrackerConfig}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BetterFeedback(child: ShakeFeedback(child: child, issueTrackerConfig: issueTrackerConfig));
  }
}
