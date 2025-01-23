import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http_client_cache/http_client_cache.dart';
import 'package:inject_annotation/inject_annotation.dart';
import 'package:path_provider/path_provider.dart';

import 'main.inject.dart' as g;
import 'src/api/api.dart';
import 'src/features/app/my_app.dart';
import 'src/utils/logger.dart';

Future<void> main() async {
  if (kDebugMode) {
    // enable http(s) proxy (like Charles) for debugging
    //HttpOverrides.global = _HttpOverrides();

    // slow down animations
    //timeDilation = 2.0;

    //debugRepaintRainbowEnabled = true;
    //debugRepaintTextRainbowEnabled = true;
  }

  // needed for getApplicationCacheDirectory
  WidgetsFlutterBinding.ensureInitialized();

  // Create the cache here and pass it to the ApiModule
  // to prevent the ApiModule to be asychronously. This
  // makes it possible to inject the http.Client synchronously.
  final httpCache = HttpCache();
  final cacheDirectory = await getApplicationCacheDirectory();
  await httpCache.initLocal(cacheDirectory);
  final apiModule = ApiModule(httpCache: httpCache);

  final mainComponent = MainComponent.create(apiModule: apiModule);
  final app = mainComponent.myAppFactory.create();
  runApp(app);
}

@Component([
  LoggerModule,
  ApiModule,
])
abstract class MainComponent {
  static const create = g.MainComponent$Component.create;

  @inject
  MyAppFactory get myAppFactory;
}

// HttpOverrides to see the http(s) traffic in Charles Proxy.
// ignore: unused_element
class _HttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)..badCertificateCallback = (_, __, ___) => true;

  @override
  String findProxyFromEnvironment(_, __) => 'PROXY 10.0.1.1:8888;';
}
