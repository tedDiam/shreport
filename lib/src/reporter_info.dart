/// Optional reporter identity provided by the host application.
/// Pass this to [ShreportWrapper] so that the reporter's name and/or email
/// are attached to every issue created in the issue tracker.
class ReporterInfo {
  final String? name;
  final String? email;

  const ReporterInfo({this.name, this.email});

  /// Returns a non-empty human-readable label, e.g. "Alice (alice@example.com)",
  /// "Alice", "alice@example.com", or null when both fields are absent.
  String? get label {
    if (name != null && email != null) return '$name ($email)';
    return name ?? email;
  }
}
