import 'dart:async';

import 'package:flutter/cupertino.dart' hide ErrorWidget;
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:inject_annotation/inject_annotation.dart';

import '../../api/models/dataset.dart';
import '../../api/models/items.dart';
import '../../localization/app_localizations.dart';
import '../../widgets/item_widgets.dart';
import '../../widgets/loading_state_widgets.dart';
import '../../widgets/platform_widget.dart';
import 'home_page_controller.dart';

@assistedFactory
abstract class HomePageFactory {
  HomePage create({Key? key});
}

class HomePage extends StatelessWidget {
  @assistedInject
  const HomePage({
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
    required this.controllerProvider,
    required this.itemSliverListFactory,
  });

  final Provider<HomePageController> controllerProvider;
  final ItemSliverListFactory itemSliverListFactory;

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  late final HomePageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controllerProvider.get();
    unawaited(_controller.loadData());
  }

  @override
  Widget build(BuildContext context) {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final isLoading = _controller.isLoading;
        final hasLoadingError = _controller.hasLoadingError;
        final items = _controller.items;

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
                      selectedItem: _controller.selectedDataSet,
                      items: _controller.dataSets,
                      onChangeListener: (dataSet) => _controller.selectedDataSet = dataSet,
                    ),
                  ),
                ),
              ),
              CupertinoSliverRefreshControl(
                onRefresh: _controller.loadData,
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
                    items: _controller.dataSets,
                    onChangeListener: (dataSet) => _controller.selectedDataSet = dataSet,
                  ),
                ],
              ),
              //SliverToBoxAdapter(child: ,),
            ],
            // const LoadingSliver(),
            widget.itemSliverListFactory.create(
              items: items,
              isLoading: isLoading,
              hasLoadingError: hasLoadingError,
            ),
          ],
        );

        if (!isIos) {
          body = RefreshIndicator(
            edgeOffset: MediaQuery.of(context).padding.top + kToolbarHeight,
            onRefresh: _controller.loadData,
            child: body,
          );
        }

        return body;
      },
    );
  }

  Future<void> _showCupertinoPicker({
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
  });

  final List<Item>? items;
  final bool isLoading;
  final bool hasLoadingError;
  final TeaserItemWidgetFactory teaserItemWidgetFactory;
  final SliderItemWidgetFactory sliderItemWidgetFactory;

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
              final BrandSliderItem brandItem => BrandSliderItemWidget(item: brandItem),
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
              final BrandSliderItem brandItem => BrandSliderItemWidget(item: brandItem),
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
