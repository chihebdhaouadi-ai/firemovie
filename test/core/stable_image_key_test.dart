import 'package:film_wise_mobile/core/stable_image_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('re-signed S3 links of one file share a cache key', () {
    const a = 'https://b.s3.amazonaws.com/conversation_photos/a.png'
        '?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20261118T100000Z'
        '&X-Amz-Signature=aaa';
    const b = 'https://b.s3.amazonaws.com/conversation_photos/a.png'
        '?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20261118T100004Z'
        '&X-Amz-Signature=bbb';
    expect(stableImageKey(a), stableImageKey(b));
    expect(stableImageKey(a),
        'https://b.s3.amazonaws.com/conversation_photos/a.png');
  });

  test('other URLs are kept as they are', () {
    const tmdb = 'https://image.tmdb.org/t/p/w500/x.jpg';
    const query = 'https://example.test/pic.png?size=large';
    expect(stableImageKey(tmdb), tmdb);
    expect(stableImageKey(query), query);
  });
}
