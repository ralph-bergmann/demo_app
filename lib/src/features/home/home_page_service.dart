import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inject_annotation/inject_annotation.dart';
import 'package:logging/logging.dart';

import '../../api/models/items.dart';
import 'home_page_controller.dart';

/// Service for [HomePageController] to load data from API.
/// In a more complex app, this would use a repository to load data from API and/or database.
/// In this case, it's just a simple call to an API.
@inject
@singleton
class HomePageService {
  const HomePageService({
    required http.Client client,
    required Logger logger,
  })  : _client = client,
        _logger = logger;

  final http.Client _client;
  final Logger _logger;

  Future<Items> loadData(String url) async {
    _logger.info('load data url: $url');
    final response = await _client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final items = Items.fromJson(jsonDecode(response.body) as List<dynamic>);
      return items;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
