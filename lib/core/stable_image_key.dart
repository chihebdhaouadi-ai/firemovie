/// A cache key for an image URL that stays the same across refreshes.
///
/// Uploaded files are served from S3 with signed links, and every API
/// response signs them again (new date and signature in the query). Used as
/// the cache key as is, each refresh would look like a new picture: the image
/// is dropped, downloaded again and flickers. The signature is dropped here,
/// so the same file keeps the same key; other URLs are returned unchanged.
String stableImageKey(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasQuery) return url;
  final signed = uri.queryParameters.keys
      .any((key) => key.toLowerCase().startsWith('x-amz-'));
  return signed
      ? uri.replace(query: '').toString().replaceFirst(RegExp(r'\?$'), '')
      : url;
}
