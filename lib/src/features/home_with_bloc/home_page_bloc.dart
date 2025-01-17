import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inject_annotation/inject_annotation.dart';

import '../../api/api_repository.dart';
import '../../api/models/dataset.dart';
import '../../api/models/items.dart';

// BLoC
@inject
class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  HomePageBloc({
    required this.repository,
  }) : super(HomePageState.initial()) {
    on<LoadDataSetRequest>(_onLoadDataSet);
    on<SelectDataSet>(_onSelectDataSet);
    on<FilterByGender>(_onFilterByGender);
  }

  final ApiRepository repository;

  Future<void> _onLoadDataSet(
    LoadDataSetRequest event,
    Emitter<HomePageState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, hasLoadingError: false));
    try {
      final items = await repository.loadData(state.selectedDataSet.url);
      emit(
        state.copyWith(
          isLoading: false,
          allItems: items.items,
        ),
      );

      // Apply current filter to new data
      _onFilterByGender(FilterByGender(state.selectedGender), emit);
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          hasLoadingError: true,
        ),
      );
    }
  }

  void _onSelectDataSet(
    SelectDataSet event,
    Emitter<HomePageState> emit,
  ) {
    emit(state.copyWith(selectedDataSet: event.dataSet));
    add(const LoadDataSetRequest());
  }

  void _onFilterByGender(FilterByGender event, Emitter<HomePageState> emit) {
    if (event.gender == null || event.gender == Gender.all) {
      emit(
        state.copyWith(
          filteredItems: state.allItems,
          selectedGender: Gender.all,
        ),
      );
      return;
    }

    // Create new list with filtered SliderItems
    final updatedItems = state.allItems
        .map(
          (item) => switch (item) {
            SliderItem() => SliderItem(
                id: item.id,
                attributes: item.attributes.where((attr) => attr.gender == event.gender).toList(),
              ),
            _ => item,
          },
        )
        .toList();

    // Filter items based on gender
    final filteredItems = updatedItems
        .where(
          (item) => switch (item) {
            TeaserItem() => item.gender == event.gender,
            SliderItem() => item.attributes.isNotEmpty,
            _ => false
          },
        )
        .toList();

    emit(
      state.copyWith(
        filteredItems: filteredItems,
        selectedGender: event.gender,
      ),
    );
  }
}

// States
class HomePageState {
  HomePageState._({
    required this.isLoading,
    required this.hasLoadingError,
    required this.allItems,
    required this.filteredItems,
    required this.selectedGender,
    required this.selectedDataSet,
  });

  factory HomePageState.initial() => HomePageState._(
        isLoading: false,
        hasLoadingError: false,
        allItems: [],
        filteredItems: [],
        selectedGender: Gender.all,
        selectedDataSet: DataSet.dataSet1,
      );

  /// available data sets
  final dataSets = DataSet.values;

  /// loading state, true if data is loading
  bool isLoading = false;

  /// loading error, true if data loading failed
  bool hasLoadingError = false;

  /// Holds all unfiltered items
  final List<Item> allItems;

  /// Holds currently filtered items
  final List<Item> filteredItems;

  /// selected gender
  final Gender selectedGender;

  /// selected data set
  final DataSet selectedDataSet;

  HomePageState copyWith({
    bool? isLoading,
    bool? hasLoadingError,
    List<Item>? allItems,
    List<Item>? filteredItems,
    Gender? selectedGender,
    DataSet? selectedDataSet,
  }) =>
      HomePageState._(
        isLoading: isLoading ?? this.isLoading,
        hasLoadingError: hasLoadingError ?? this.hasLoadingError,
        allItems: allItems ?? this.allItems,
        filteredItems: filteredItems ?? this.filteredItems,
        selectedGender: selectedGender ?? this.selectedGender,
        selectedDataSet: selectedDataSet ?? this.selectedDataSet,
      );
}

// Events
sealed class HomePageEvent {
  const HomePageEvent();
}

/// load data set with given url
final class LoadDataSetRequest extends HomePageEvent {
  const LoadDataSetRequest();
}

/// select data set
final class SelectDataSet extends HomePageEvent {
  const SelectDataSet(this.dataSet);
  final DataSet dataSet;
}

class FilterByGender extends HomePageEvent {
  FilterByGender(this.gender);

  final Gender? gender;
}
