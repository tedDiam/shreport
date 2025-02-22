


sealed class IssueTrackerConfig {
  const IssueTrackerConfig();
}

class JiraIssueTracker extends IssueTrackerConfig {
  final String domainName;
  final String apiToken;
  final String projectKey;

  const JiraIssueTracker({
    required this.domainName,
    required this.apiToken,
    required this.projectKey,
  });
}

class AsanaIssueTracker extends IssueTrackerConfig {
  final String workspaceId;
  final String accessToken;

  const AsanaIssueTracker({
    required this.workspaceId,
    required this.accessToken,
  });
}

class GitlabIssueTracker extends IssueTrackerConfig {
  final String domainName;
  final String apiToken;
  final String projectId;

  const GitlabIssueTracker({
    required this.domainName,
    required this.apiToken,
    required this.projectId,
  });
}