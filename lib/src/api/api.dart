import 'package:http/http.dart';
import 'package:http_cache/http_cache.dart';
import 'package:http_intercept/http_intercept.dart';
import 'package:http_logger/http_logger.dart';
import 'package:inject_annotation/inject_annotation.dart';

import 'image_cache_interceptor.dart';

@module
class ApiModule {
  const ApiModule({
    required HttpCache httpCache,
  }) : _cache = httpCache;

  final HttpCache _cache;

  @provides
  @singleton
  Client provideClient({required ImageCacheInterceptor imageCacheInterceptor}) => HttpClientProxy(
        interceptors: [
          HttpLogger(),
          imageCacheInterceptor,
          _cache,
        ],
      );
}
