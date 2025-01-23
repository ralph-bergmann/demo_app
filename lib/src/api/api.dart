import 'package:http/http.dart';
import 'package:http_client_cache/http_client_cache.dart';
import 'package:http_client_interceptor/http_client_interceptor.dart';
import 'package:http_client_logger/http_client_logger.dart';
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
