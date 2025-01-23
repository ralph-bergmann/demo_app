import 'dart:io';

import 'package:http/http.dart';
import 'package:http_client_cache/http_client_cache.dart';
import 'package:http_client_interceptor/http_client_interceptor.dart';
import 'package:inject_annotation/inject_annotation.dart';

@inject
@singleton
class ImageCacheInterceptor extends HttpInterceptorWrapper {
  @override
  Future<OnResponse> onResponse(StreamedResponse response) async {
    final cacheControlHeader = response.headers[HttpHeaders.cacheControlHeader];
    if (cacheControlHeader == null) {
      return OnResponse.next(response);
    }

    // Add/override the cache control max-age parameter to cache the response.
    // In production, there should be some logic to having different caching
    // strategies for different content/mime types and/or urls.
    // It currently only modifies the cache-controll header for the images, because
    // the GitHub gist already has an cache-control max-age header we don't override.
    var cacheControl = CacheControl.parse(cacheControlHeader);
    if (cacheControl.maxAge == null || cacheControl.maxAge == Duration.zero) {
      cacheControl = cacheControl.copyWith(maxAge: const Duration(hours: 1));
    }

    // Create new headers map with the updated cache control
    final newHeaders = Map<String, String>.from(response.headers);
    newHeaders[HttpHeaders.cacheControlHeader] = cacheControl.toString();

    final newResponse = StreamedResponse(
      response.stream,
      response.statusCode,
      contentLength: response.contentLength,
      request: response.request,
      headers: newHeaders,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );

    return OnResponse.next(newResponse);
  }
}
