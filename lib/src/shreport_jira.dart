import 'dart:convert';
import 'dart:io';

import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shreport/src/issue_tracker_config.dart';

/// This file is from:
/// https://github.com/encalv/feedback_jira/blob/main/lib/src/feedback_jira.dart

/// This is an extension to make it easier to call
/// [showAndUploadToJira].
extension BetterFeedbackX on FeedbackController {
  /// Example usage:
  /// ```dart
  /// import 'package:feedback_jira/feedback_jira.dart';
  ///
  /// RaisedButton(
  ///   child: Text('Click me'),
  ///   onPressed: (){
  ///     BetterFeedback.of(context).showAndUploadToJira
  ///       domainName: 'jira-project',
  ///       apiToken: 'jira-api-token',
  ///     );
  ///   }
  /// )
  /// ```
  /// The API token needs access to:
  ///   - read_api
  ///   - write_repository
  /// See https://docs.gitlab.com/ee/user/project/settings/project_access_tokens.html#limiting-scopes-of-a-project-access-token
  void showAndUploadToJira({
    required JiraIssueTracker issueTracker,
    http.Client? client,
  }) {
    show(uploadToJira(
      domainName: issueTracker.domainName,
      apiToken: issueTracker.apiToken,
      client: client,
      projectKey: issueTracker.projectKey
    ));
  }


}

/// See [BetterFeedbackX.showAndUploadToJira].
/// This is just [visibleForTesting].
@visibleForTesting
OnFeedbackCallback uploadToJira({
  required String domainName,
  required String apiToken,
  required String projectKey,
  String? gitlabUrl,
  Map<String, dynamic>? customBody,
  http.Client? client,
}) {
  final httpClient = client ?? http.Client();
  final baseUrl = '$domainName.atlassian.net';

  return (UserFeedback feedback) async {

    final body = customBody ??
        {
          "fields": {
            "project": {"key": projectKey},
            "summary": feedback.text,
            "issuetype": {"name": "Bug"}
          }
        };
    final issueUri = Uri.https(baseUrl, '/rest/api/3/issue');

    print('issueUri: $issueUri');

    final username = 'serge.diame@paynah.com';
    final credentials = base64Encode(utf8.encode('$username:$apiToken'));

    try {
      final response = await httpClient.post(
        issueUri,
        body: jsonEncode(body),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          //HttpHeaders.authorizationHeader: 'Basic $apiToken',
          HttpHeaders.authorizationHeader: 'Basic $credentials',
        },
      );
      final int statusCode = response.statusCode;

      print('statusCode: $statusCode');
      if (statusCode >= 200 && statusCode < 400) {
        print('response.body: ${response.body}');
        final resp = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final ticketId = resp['id'] as String;

        try {
          final attachmentsUri = Uri.https(baseUrl, '/rest/api/3/issue/$ticketId/attachments');
          final request = MultipartRequest('POST', attachmentsUri);
          request.headers['X-Atlassian-Token'] = 'no-check';
          request.headers['Accept'] = 'application/json';
          request.headers['Authorization'] = 'Basic $credentials';
          final httpImage = MultipartFile.fromBytes(
            'file',
            feedback.screenshot,
            filename: 'screenshot.png',
            contentType: MediaType('image', 'png'),
          );
          request.files.add(httpImage);
          await request.send();
        } catch (e) {
          rethrow;
        }
      } else {
        throw HttpException('Erreur $statusCode');
      }
    } catch (e) {
      rethrow;
    }
  };
}
