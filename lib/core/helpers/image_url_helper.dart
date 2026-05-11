String normalizeImageUrl(String? url) {
  final value = url?.trim() ?? '';
  if (value.isEmpty) return '';

  final lower = value.toLowerCase();
  if (lower.startsWith('/data/') ||
      lower.startsWith('file://') ||
      lower.startsWith('content://') ||
      lower.startsWith('c:\\') ||
      lower.startsWith('n:\\')) {
    return '';
  }

  final uri = Uri.tryParse(value);
  if (uri == null || !uri.hasScheme) return '';
  if (uri.scheme != 'http' && uri.scheme != 'https') return '';

  final host = uri.host.toLowerCase();
  if (!host.contains('drive.google.com')) return value;

  final id = _extractGoogleDriveId(uri);
  if (id == null || id.isEmpty) return value;
  return 'https://drive.google.com/thumbnail?id=$id&sz=w1000';
}

String? _extractGoogleDriveId(Uri uri) {
  final queryId = uri.queryParameters['id'];
  if (queryId != null && queryId.isNotEmpty) return queryId;

  final segments = uri.pathSegments;
  final fileIndex = segments.indexOf('d');
  if (fileIndex >= 0 && segments.length > fileIndex + 1) {
    return segments[fileIndex + 1];
  }

  if (segments.isNotEmpty && segments.first == 'thumbnail') {
    return uri.queryParameters['id'];
  }

  return null;
}
