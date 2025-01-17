import 'dart:async';

import 'package:flutter/cupertino.dart' hide ErrorWidget;
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inject_annotation/inject_annotation.dart';

import '../../api/models/dataset.dart';
import '../../api/models/items.dart';
import '../../localization/app_localizations.dart';
import '../../widgets/gender_filter_widget.dart';
import '../../widgets/item_widgets.dart';
import '../../widgets/loading_state_widgets.dart';
import '../../widgets/platform_widget.dart';
import 'home_page_bloc.dart';

@assistedFactory
abstract class HomePageWithBlocFactory {
  HomePageWithBloc create({Key? key});
}

class HomePageWithBloc extends StatelessWidget {
  @assistedInject
  const HomePageWithBloc({
    @assisted super.key,
    required this.homePageBodyFactory,
  });

  final HomePageBodyFactory homePageBodyFactory;

  @override
  Widget build(BuildContext context) => PlatformWidget(
        cupertinoWidget: (context) => CupertinoPageScaffold(
          child: homePageBodyFactory.create(),
        ),
        materialWidget: (context) => Scaffold(
          body: homePageBodyFactory.create(),
        ),
      );
}

@assistedFactory
abstract class HomePageBodyFactory {
  HomePageBody create({Key? key});
}

class HomePageBody extends StatefulWidget {
  @assistedInject
  const HomePageBody({
    @assisted super.key,
    required this.itemSliverListFactory,
  });

  final ItemSliverListFactory itemSliverListFactory;

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  @override
  void initState() {
    super.initState();
    context.read<HomePageBloc>().add(const LoadDataSetRequest());
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<HomePageBloc, HomePageState>(
        builder: (context, state) {
          final isIos = Theme.of(context).platform == TargetPlatform.iOS;

          Widget body = CustomScrollView(
            slivers: [
              if (isIos) ...[
                CupertinoSliverNavigationBar(
                  largeTitle: RepaintBoundary(
                    child: Text(AppLocalizations.of(context).appTitle),
                  ),
                  trailing: CupertinoButton(
                    child: const Icon(CupertinoIcons.gear),
                    onPressed: () => unawaited(
                      _showCupertinoPicker(
                        context,
                        selectedItem: state.selectedDataSet,
                        items: state.dataSets,
                        onChangeListener: (dataSet) =>
                            context.read<HomePageBloc>().add(SelectDataSet(dataSet)),
                      ),
                    ),
                  ),
                ),
                CupertinoSliverRefreshControl(
                  onRefresh: () {
                    context.read<HomePageBloc>().add(const LoadDataSetRequest());
                    return Future.value();
                  },
                ),
              ] else ...[
                SliverAppBar(
                  pinned: true,
                  expandedHeight: kToolbarHeight,
                  flexibleSpace: FlexibleSpaceBar(
                    title: RepaintBoundary(
                      child: Text(AppLocalizations.of(context).appTitle),
                    ),
                  ),
                  actions: [
                    _MaterialMenu(
                      items: state.dataSets,
                      onChangeListener: (dataSet) =>
                          context.read<HomePageBloc>().add(SelectDataSet(dataSet)),
                    ),
                  ],
                ),
              ],
              GenderFilterWidget(
                selectedGender: state.selectedGender,
                onGenderSelected: (gender) {
                  context.read<HomePageBloc>().add(FilterByGender(gender));
                },
              ),
              widget.itemSliverListFactory.create(
                items: state.filteredItems,
                isLoading: state.isLoading,
                hasLoadingError: state.hasLoadingError,
              ),
            ],
          );

          if (!isIos) {
            body = RefreshIndicator(
              edgeOffset: MediaQuery.of(context).padding.top + kToolbarHeight,
              onRefresh: () {
                context.read<HomePageBloc>().add(const LoadDataSetRequest());
                return Future.value();
              },
              child: body,
            );
          }

          return body;
        },
      );

  Future<void> _showCupertinoPicker(
    BuildContext context, {
    required DataSet selectedItem,
    required List<DataSet> items,
    required Function(DataSet dataSet) onChangeListener,
  }) =>
      showCupertinoModalPopup<void>(
        context: context,
        builder: (context) => Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: CupertinoPicker.builder(
              magnification: 1.22,
              squeeze: 1.2,
              useMagnifier: true,
              itemExtent: 32,
              scrollController: FixedExtentScrollController(
                initialItem: selectedItem.index,
              ),
              onSelectedItemChanged: (selectedIndex) {
                onChangeListener(items[selectedIndex]);
              },
              itemBuilder: (context, index) => Center(child: Text(items[index].name)),
              childCount: items.length,
            ),
          ),
        ),
      );
}

class _MaterialMenu extends StatefulWidget {
  const _MaterialMenu({
    required this.items,
    required this.onChangeListener,
  });

  final List<DataSet> items;
  final Function(DataSet dataSet) onChangeListener;

  @override
  State<_MaterialMenu> createState() => _MaterialMenuState();
}

class _MaterialMenuState extends State<_MaterialMenu> {
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Menu Button');

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: MenuAnchor(
          childFocusNode: _buttonFocusNode,
          menuChildren: widget.items
              .map(
                (item) => MenuItemButton(
                  onPressed: () => widget.onChangeListener(item),
                  child: Text(item.name),
                ),
              )
              .toList(),
          builder: (_, controller, child) => IconButton(
            focusNode: _buttonFocusNode,
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            icon: const Icon(Icons.more_vert),
          ),
        ),
      );
}

@assistedFactory
abstract class ItemSliverListFactory {
  ItemsSliverList create({
    Key? key,
    required List<Item>? items,
    required bool isLoading,
    required bool hasLoadingError,
  });
}

// [SliverList] for [Item]s which handles loading and error states
class ItemsSliverList extends StatelessWidget {
  @assistedInject
  const ItemsSliverList({
    @assisted super.key,
    @assisted required this.items,
    @assisted required this.isLoading,
    @assisted required this.hasLoadingError,
    required this.teaserItemWidgetFactory,
    required this.sliderItemWidgetFactory,
    required this.brandSliderItemWidgetFactory,
  });

  final List<Item>? items;
  final bool isLoading;
  final bool hasLoadingError;
  final TeaserItemWidgetFactory teaserItemWidgetFactory;
  final SliderItemWidgetFactory sliderItemWidgetFactory;
  final BrandSliderItemWidgetFactory brandSliderItemWidgetFactory;

  @override
  Widget build(BuildContext context) {
    final hasItems = items?.isNotEmpty ?? false;

    final config = switch ((hasItems, isLoading, hasLoadingError)) {
      // no items and loading, show loading indicator
      (false, true, _) => _ListConfig(
          itemBuilder: (_, __) => FutureBuilder(
            future: Future.delayed(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              // hide the loading indicator for 1 second
              // people saying that this feels faster than with a loading indicator
              // https://www.smashingmagazine.com/2016/12/best-practices-for-animated-progress-indicators/#use-a-progress-indicator-for-any-action-that-takes-longer-than-one-second
              if (snapshot.connectionState == ConnectionState.done) {
                return const LoadingWidget();
              }
              return const SizedBox.shrink();
            },
          ),
          itemCount: 1,
        ),

      // no items with loading error, show error message
      (false, _, true) => _ListConfig(
          itemBuilder: (_, __) => const ErrorWidget(),
          itemCount: 1,
        ),

      // has items but got an error while loading, show items with error message
      (true, _, true) => _ListConfig(
          itemBuilder: (context, index) {
            if (index == 0) {
              return const ErrorWidget();
            }

            final item = items![index - 1];
            return switch (item) {
              final TeaserItem teaserItem => teaserItemWidgetFactory.create(item: teaserItem),
              final SliderItem sliderItem => sliderItemWidgetFactory.create(item: sliderItem),
              final BrandSliderItem brandItem =>
                brandSliderItemWidgetFactory.create(item: brandItem),
            };
          },
          itemCount: items!.length + 1,
        ),

      // show items
      (true, _, _) => _ListConfig(
          itemBuilder: (context, index) {
            final item = items![index];
            return switch (item) {
              final TeaserItem teaserItem => teaserItemWidgetFactory.create(item: teaserItem),
              final SliderItem sliderItem => sliderItemWidgetFactory.create(item: sliderItem),
              final BrandSliderItem brandItem =>
                brandSliderItemWidgetFactory.create(item: brandItem),
            };
          },
          itemCount: items!.length,
        ),

      // fallback if none of the above conditions are met
      _ => _ListConfig(
          itemBuilder: (_, __) => const SizedBox.shrink(),
          itemCount: 0,
        ),
    };

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        config.itemBuilder,
        childCount: config.itemCount,
      ),
    );
  }
}

// Config for [Item]s [SliverList]
class _ListConfig {
  const _ListConfig({
    required this.itemBuilder,
    required this.itemCount,
  });

  final NullableIndexedWidgetBuilder itemBuilder;
  final int itemCount;
}
