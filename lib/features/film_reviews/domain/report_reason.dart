/// Why a viewer reports a take to moderators.
enum ReportReason {
  spam('spam'),
  harassment('harassment'),
  hate('hate'),
  spoiler('spoiler'),
  other('other');

  const ReportReason(this.apiValue);

  final String apiValue;
}
