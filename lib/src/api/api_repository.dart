import 'dart:convert';

import 'package:http/http.dart';
import 'package:inject_annotation/inject_annotation.dart';
import 'package:logging/logging.dart';

import 'models/items.dart';

@inject
@singleton
class ApiRepository {
  const ApiRepository({
    required Client client,
    required Logger logger,
  })  : _client = client,
        _logger = logger;

  final Client _client;
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
