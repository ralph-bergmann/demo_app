import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inject_annotation/inject_annotation.dart';

import '../../api/models/dataset.dart';
import '../../api/models/items.dart';
import 'home_page.dart';
import 'home_page_service.dart';

/// Controller for [HomePage].
/// Loads data from [HomePageService] and handles the loading state.
@inject
class HomePageController extends ChangeNotifier {
  HomePageController({
    required HomePageService homePageServise,
  }) : _homePageService = homePageServise;

  final HomePageService _homePageService;

  /// available data sets
  final dataSets = DataSet.values;

  /// selected data set
  DataSet _selectedDataSet = DataSet.dataSet1;
  DataSet get selectedDataSet => _selectedDataSet;
  set selectedDataSet(DataSet dataSet) {
    _selectedDataSet = dataSet;
    unawaited(loadData());
  }

  /// loading state, true if data is loading
  bool isLoading = false;

  /// loading error, true if data loading failed
  bool hasLoadingError = false;

  /// items to display
  List<Item>? items;

  /// load data from [HomePageService]
  /// sets [items] and handles loading and error states
  Future<void> loadData() async {
    try {
      isLoading = true;
      hasLoadingError = false;
      notifyListeners();

      final data = await _homePageService.loadData(_selectedDataSet.url);
      items = data.items;
    } catch (e) {
      // We don't need to print the error here, because it's already logged by [HttpLogger].
      // The ui will show the error message, depending if there are already any items to show or not.
      // For this demo we handle all errors the same way.
      hasLoadingError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
