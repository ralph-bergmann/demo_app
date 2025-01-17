import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_image_provider/http_image_provider.dart';
import 'package:inject_annotation/inject_annotation.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/models/items.dart';
import '../localization/app_localizations.dart';

@assistedFactory
abstract class TeaserItemWidgetFactory {
  TeaserItemWidget create({
    Key? key,
    required TeaserItem item,
  });
}

/// Widget which displays a [TeaserItem] in a [_ItemWidget].
class TeaserItemWidget extends StatelessWidget {
  @assistedInject
  const TeaserItemWidget({
    @assisted super.key,
    @assisted required this.item,
    required this.httpClient,
  });

  final TeaserItem item;
  final Client httpClient;

  @override
  Widget build(BuildContext context) => _ItemWidget(
        key: ValueKey(item),
        httpClient: httpClient,
        imageUrl: item.imageUrl,
        url: item.url,
        gender: item.gender,
        headline: item.headline,
      );
}

@assistedFactory
abstract class SliderItemWidgetFactory {
  SliderItemWidget create({
    Key? key,
    required SliderItem item,
  });
}

/// Widget which displays a [SliderItem] in a [_SliderAttributesCarouselWidget].
class SliderItemWidget extends StatelessWidget {
  @assistedInject
  const SliderItemWidget({
    @assisted super.key,
    @assisted required this.item,
    required this.httpClient,
  });

  final SliderItem item;
  final Client httpClient;

  @override
  Widget build(BuildContext context) => _SliderAttributesCarouselWidget(
        httpClient: httpClient,
        items: item.attributes,
      );
}

@assistedFactory
abstract class BrandSliderItemWidgetFactory {
  BrandSliderItemWidget create({
    Key? key,
    required BrandSliderItem item,
  });
}

/// Widget which displays a [BrandSliderItem]. Loads them with a [_NetworkItems] widget and displays them in a [_SliderAttributesCarouselWidget].
class BrandSliderItemWidget extends StatelessWidget {
  @assistedInject
  const BrandSliderItemWidget({
    @assisted super.key,
    @assisted required this.item,
    required this.httpClient,
  });

  final BrandSliderItem item;
  final Client httpClient;

  @override
  Widget build(BuildContext context) => Card(
        child: AspectRatio(
          aspectRatio: 300 / 200,
          child: _NetworkItems(
            httpClient: httpClient,
            url: item.itemsUrl,
            loadingBuilder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorBuilder: (context, error) => Center(
              child: Text('Failed to load items: $error'),
            ),
            builder: (context, items) => _SliderAttributesCarouselWidget(
              httpClient: httpClient,
              items: items,
            ),
          ),
        ),
      );
}

/// Widget which displays a list of [SliderAttribute]s as [_ItemWidget] in a [CarouselSlider].
class _SliderAttributesCarouselWidget extends StatefulWidget {
  const _SliderAttributesCarouselWidget({
    required this.httpClient,
    required this.items,
  });

  final Client httpClient;
  final List<SliderAttribute> items;

  @override
  State<_SliderAttributesCarouselWidget> createState() => _SliderAttributesCarouselWidgetState();
}

// with keep alive mixin to keep the scroll state of the slider
class _SliderAttributesCarouselWidgetState extends State<_SliderAttributesCarouselWidget>
    with AutomaticKeepAliveClientMixin {
  late final CarouselController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = CarouselController(initialItem: 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // super call needed for keep alive mixin
    super.build(context);

    return Card(
      child: AspectRatio(
        aspectRatio: 300 / 200,
        child: CarouselSlider(
          options: CarouselOptions(height: 400),
          items: widget.items
              .map(
                (attribute) => Builder(
                  builder: (context) => Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: _ItemWidget(
                      key: ValueKey(attribute),
                      httpClient: widget.httpClient,
                      imageUrl: attribute.imageUrl,
                      url: attribute.url,
                      gender: attribute.gender,
                      headline: attribute.headline,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

/// Widget which loads BrandSliderItems from a network endpoint.
class _NetworkItems extends StatefulWidget {
  const _NetworkItems({
    required this.httpClient,
    required this.url,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
  });

  final Client httpClient;
  final String url;
  final Widget Function(BuildContext context, List<SliderAttribute> items) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  @override
  State<_NetworkItems> createState() => _NetworkItemsState();
}

class _NetworkItemsState extends State<_NetworkItems> {
  late Future<List<SliderAttribute>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    // ignore: discarded_futures
    _itemsFuture = _loadItems();
  }

  @override
  void didUpdateWidget(_NetworkItems oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      // ignore: discarded_futures
      _itemsFuture = _loadItems();
    }
  }

  Future<List<SliderAttribute>> _loadItems() async {
    final response = await widget.httpClient.get(Uri.parse(widget.url));
    if (response.statusCode == 200) {
      return BrandItems.fromJson(jsonDecode(response.body)).items;
    }
    throw Exception('Failed to load items');
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<SliderAttribute>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return widget.errorBuilder?.call(context, snapshot.error!) ??
                Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return widget.loadingBuilder?.call(context) ??
                const Center(child: CircularProgressIndicator());
          }

          return widget.builder(context, snapshot.data!);
        },
      );
}

/// Theme extension for the ItemWidget.
class ItemWidgetTheme extends ThemeExtension<ItemWidgetTheme> {
  const ItemWidgetTheme({
    required this.headlineTextStyle,
  });

  final TextStyle headlineTextStyle;

  @override
  ThemeExtension<ItemWidgetTheme> copyWith({
    TextStyle? headlineTextStyle,
  }) =>
      ItemWidgetTheme(
        headlineTextStyle: headlineTextStyle ?? this.headlineTextStyle,
      );

  @override
  ThemeExtension<ItemWidgetTheme> lerp(
    covariant ThemeExtension<ItemWidgetTheme>? other,
    double t,
  ) {
    if (other is! ItemWidgetTheme) {
      return this;
    }

    return ItemWidgetTheme(
      headlineTextStyle: TextStyle.lerp(headlineTextStyle, other.headlineTextStyle, t)!,
    );
  }
}

/// Widget which displays a single item in a Card.
class _ItemWidget extends StatelessWidget {
  const _ItemWidget({
    required super.key,
    required this.httpClient,
    required this.imageUrl,
    required this.url,
    required this.gender,
    required this.headline,
  });

  final Client httpClient;
  final String imageUrl;
  final String url;
  final Gender gender;
  final String headline;

  @override
  Widget build(BuildContext context) {
    final itemWidgetTheme = Theme.of(context).extension<ItemWidgetTheme>()!;

    return GestureDetector(
      onTap: _openUrl,
      child: Card(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 300 / 200,
            child: Stack(
              children: [
                Positioned.fill(
                  child: SoftEdgeBlur(
                    edges: [
                      EdgeBlur(
                        type: EdgeType.bottomEdge,
                        size: 80,
                        sigma: 50,
                        tintColor: Theme.of(context).colorScheme.surface.withAlpha(40),
                        controlPoints: [
                          ControlPoint(
                            position: 0.5,
                            type: ControlPointType.visible,
                          ),
                          ControlPoint(
                            position: 1,
                            type: ControlPointType.transparent,
                          ),
                        ],
                      ),
                    ],
                    child: Image(
                      image: HttpImageProvider(
                        Uri.parse(imageUrl),
                        client: httpClient,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: DefaultTextStyle.merge(
                      style: itemWidgetTheme.headlineTextStyle,
                      child: Text(
                        '${AppLocalizations.of(context).greeting(gender: gender.name)}: $headline',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openUrl() => unawaited(launchUrl(Uri.parse(url)));
}
