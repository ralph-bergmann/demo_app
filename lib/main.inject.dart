// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'main.dart' as _i1;
import 'src/utils/logger.dart' as _i2;
import 'src/api/api.dart' as _i3;
import 'src/features/app/my_app.dart' as _i4;
import 'package:inject_annotation/inject_annotation.dart' as _i5;
import 'src/api/image_cache_interceptor.dart' as _i6;
import 'package:http/src/client.dart' as _i7;
import 'package:logging/src/logger.dart' as _i8;
import 'src/api/api_repository.dart' as _i9;
import 'src/features/home_with_bloc/home_page_bloc.dart' as _i10;
import 'src/widgets/item_widgets.dart' as _i11;
import 'package:flutter/src/foundation/key.dart' as _i12;
import 'src/api/models/items.dart' as _i13;
import 'src/features/home_with_bloc/home_page_with_bloc.dart' as _i14;

class MainComponent$Component implements _i1.MainComponent {
  factory MainComponent$Component.create({
    _i2.LoggerModule? loggerModule,
    required _i3.ApiModule apiModule,
  }) =>
      MainComponent$Component._(
        loggerModule ?? _i2.LoggerModule(),
        apiModule,
      );

  MainComponent$Component._(
    this._loggerModule,
    this._apiModule,
  ) {
    _initialize();
  }

  final _i2.LoggerModule _loggerModule;

  final _i3.ApiModule _apiModule;

  late final _ImageCacheInterceptor$Provider _imageCacheInterceptor$Provider;

  late final _Client$Provider _client$Provider;

  late final _Logger$Provider _logger$Provider;

  late final _ApiRepository$Provider _apiRepository$Provider;

  late final _HomePageBloc$Provider _homePageBloc$Provider;

  late final _TeaserItemWidgetFactory$Provider
      _teaserItemWidgetFactory$Provider;

  late final _SliderItemWidgetFactory$Provider
      _sliderItemWidgetFactory$Provider;

  late final _BrandSliderItemWidgetFactory$Provider
      _brandSliderItemWidgetFactory$Provider;

  late final _ItemSliverListFactory$Provider _itemSliverListFactory$Provider;

  late final _HomePageBodyFactory$Provider _homePageBodyFactory$Provider;

  late final _HomePageWithBlocFactory$Provider
      _homePageWithBlocFactory$Provider;

  late final _MyAppFactory$Provider _myAppFactory$Provider;

  void _initialize() {
    _imageCacheInterceptor$Provider = _ImageCacheInterceptor$Provider();
    _client$Provider = _Client$Provider(
      _imageCacheInterceptor$Provider,
      _apiModule,
    );
    _logger$Provider = _Logger$Provider(_loggerModule);
    _apiRepository$Provider = _ApiRepository$Provider(
      _client$Provider,
      _logger$Provider,
    );
    _homePageBloc$Provider = _HomePageBloc$Provider(_apiRepository$Provider);
    _teaserItemWidgetFactory$Provider =
        _TeaserItemWidgetFactory$Provider(_client$Provider);
    _sliderItemWidgetFactory$Provider =
        _SliderItemWidgetFactory$Provider(_client$Provider);
    _brandSliderItemWidgetFactory$Provider =
        _BrandSliderItemWidgetFactory$Provider(_client$Provider);
    _itemSliverListFactory$Provider = _ItemSliverListFactory$Provider(
      _teaserItemWidgetFactory$Provider,
      _sliderItemWidgetFactory$Provider,
      _brandSliderItemWidgetFactory$Provider,
    );
    _homePageBodyFactory$Provider =
        _HomePageBodyFactory$Provider(_itemSliverListFactory$Provider);
    _homePageWithBlocFactory$Provider =
        _HomePageWithBlocFactory$Provider(_homePageBodyFactory$Provider);
    _myAppFactory$Provider = _MyAppFactory$Provider(
      _homePageWithBlocFactory$Provider,
      _homePageBloc$Provider,
    );
  }

  @override
  _i4.MyAppFactory get myAppFactory => _myAppFactory$Provider.get();
}

class _ImageCacheInterceptor$Provider
    implements _i5.Provider<_i6.ImageCacheInterceptor> {
  _ImageCacheInterceptor$Provider();

  _i6.ImageCacheInterceptor? _singleton;

  @override
  _i6.ImageCacheInterceptor get() => _singleton ??= _i6.ImageCacheInterceptor();
}

class _Client$Provider implements _i5.Provider<_i7.Client> {
  _Client$Provider(
    this._imageCacheInterceptor$Provider,
    this._module,
  );

  final _ImageCacheInterceptor$Provider _imageCacheInterceptor$Provider;

  final _i3.ApiModule _module;

  _i7.Client? _singleton;

  @override
  _i7.Client get() => _singleton ??= _module.provideClient(
      imageCacheInterceptor: _imageCacheInterceptor$Provider.get());
}

class _Logger$Provider implements _i5.Provider<_i8.Logger> {
  _Logger$Provider(this._module);

  final _i2.LoggerModule _module;

  _i8.Logger? _singleton;

  @override
  _i8.Logger get() => _singleton ??= _module.provideLogger();
}

class _ApiRepository$Provider implements _i5.Provider<_i9.ApiRepository> {
  _ApiRepository$Provider(
    this._client$Provider,
    this._logger$Provider,
  );

  final _Client$Provider _client$Provider;

  final _Logger$Provider _logger$Provider;

  _i9.ApiRepository? _singleton;

  @override
  _i9.ApiRepository get() => _singleton ??= _i9.ApiRepository(
        client: _client$Provider.get(),
        logger: _logger$Provider.get(),
      );
}

class _HomePageBloc$Provider implements _i5.Provider<_i10.HomePageBloc> {
  const _HomePageBloc$Provider(this._apiRepository$Provider);

  final _ApiRepository$Provider _apiRepository$Provider;

  @override
  _i10.HomePageBloc get() =>
      _i10.HomePageBloc(repository: _apiRepository$Provider.get());
}

class _TeaserItemWidgetFactory$Provider
    implements _i5.Provider<_i11.TeaserItemWidgetFactory> {
  _TeaserItemWidgetFactory$Provider(this._client$Provider);

  final _Client$Provider _client$Provider;

  late final _i11.TeaserItemWidgetFactory _factory =
      _TeaserItemWidgetFactory$Factory(_client$Provider);

  @override
  _i11.TeaserItemWidgetFactory get() => _factory;
}

class _TeaserItemWidgetFactory$Factory implements _i11.TeaserItemWidgetFactory {
  const _TeaserItemWidgetFactory$Factory(this._client$Provider);

  final _Client$Provider _client$Provider;

  @override
  _i11.TeaserItemWidget create({
    _i12.Key? key,
    required _i13.TeaserItem item,
  }) =>
      _i11.TeaserItemWidget(
        key: key,
        item: item,
        httpClient: _client$Provider.get(),
      );
}

class _SliderItemWidgetFactory$Provider
    implements _i5.Provider<_i11.SliderItemWidgetFactory> {
  _SliderItemWidgetFactory$Provider(this._client$Provider);

  final _Client$Provider _client$Provider;

  late final _i11.SliderItemWidgetFactory _factory =
      _SliderItemWidgetFactory$Factory(_client$Provider);

  @override
  _i11.SliderItemWidgetFactory get() => _factory;
}

class _SliderItemWidgetFactory$Factory implements _i11.SliderItemWidgetFactory {
  const _SliderItemWidgetFactory$Factory(this._client$Provider);

  final _Client$Provider _client$Provider;

  @override
  _i11.SliderItemWidget create({
    _i12.Key? key,
    required _i13.SliderItem item,
  }) =>
      _i11.SliderItemWidget(
        key: key,
        item: item,
        httpClient: _client$Provider.get(),
      );
}

class _BrandSliderItemWidgetFactory$Provider
    implements _i5.Provider<_i11.BrandSliderItemWidgetFactory> {
  _BrandSliderItemWidgetFactory$Provider(this._client$Provider);

  final _Client$Provider _client$Provider;

  late final _i11.BrandSliderItemWidgetFactory _factory =
      _BrandSliderItemWidgetFactory$Factory(_client$Provider);

  @override
  _i11.BrandSliderItemWidgetFactory get() => _factory;
}

class _BrandSliderItemWidgetFactory$Factory
    implements _i11.BrandSliderItemWidgetFactory {
  const _BrandSliderItemWidgetFactory$Factory(this._client$Provider);

  final _Client$Provider _client$Provider;

  @override
  _i11.BrandSliderItemWidget create({
    _i12.Key? key,
    required _i13.BrandSliderItem item,
  }) =>
      _i11.BrandSliderItemWidget(
        key: key,
        item: item,
        httpClient: _client$Provider.get(),
      );
}

class _ItemSliverListFactory$Provider
    implements _i5.Provider<_i14.ItemSliverListFactory> {
  _ItemSliverListFactory$Provider(
    this._teaserItemWidgetFactory$Provider,
    this._sliderItemWidgetFactory$Provider,
    this._brandSliderItemWidgetFactory$Provider,
  );

  final _TeaserItemWidgetFactory$Provider _teaserItemWidgetFactory$Provider;

  final _SliderItemWidgetFactory$Provider _sliderItemWidgetFactory$Provider;

  final _BrandSliderItemWidgetFactory$Provider
      _brandSliderItemWidgetFactory$Provider;

  late final _i14.ItemSliverListFactory _factory =
      _ItemSliverListFactory$Factory(
    _teaserItemWidgetFactory$Provider,
    _sliderItemWidgetFactory$Provider,
    _brandSliderItemWidgetFactory$Provider,
  );

  @override
  _i14.ItemSliverListFactory get() => _factory;
}

class _ItemSliverListFactory$Factory implements _i14.ItemSliverListFactory {
  const _ItemSliverListFactory$Factory(
    this._teaserItemWidgetFactory$Provider,
    this._sliderItemWidgetFactory$Provider,
    this._brandSliderItemWidgetFactory$Provider,
  );

  final _TeaserItemWidgetFactory$Provider _teaserItemWidgetFactory$Provider;

  final _SliderItemWidgetFactory$Provider _sliderItemWidgetFactory$Provider;

  final _BrandSliderItemWidgetFactory$Provider
      _brandSliderItemWidgetFactory$Provider;

  @override
  _i14.ItemsSliverList create({
    _i12.Key? key,
    required List<_i13.Item>? items,
    required bool isLoading,
    required bool hasLoadingError,
  }) =>
      _i14.ItemsSliverList(
        key: key,
        items: items,
        isLoading: isLoading,
        hasLoadingError: hasLoadingError,
        teaserItemWidgetFactory: _teaserItemWidgetFactory$Provider.get(),
        sliderItemWidgetFactory: _sliderItemWidgetFactory$Provider.get(),
        brandSliderItemWidgetFactory:
            _brandSliderItemWidgetFactory$Provider.get(),
      );
}

class _HomePageBodyFactory$Provider
    implements _i5.Provider<_i14.HomePageBodyFactory> {
  _HomePageBodyFactory$Provider(this._itemSliverListFactory$Provider);

  final _ItemSliverListFactory$Provider _itemSliverListFactory$Provider;

  late final _i14.HomePageBodyFactory _factory =
      _HomePageBodyFactory$Factory(_itemSliverListFactory$Provider);

  @override
  _i14.HomePageBodyFactory get() => _factory;
}

class _HomePageBodyFactory$Factory implements _i14.HomePageBodyFactory {
  const _HomePageBodyFactory$Factory(this._itemSliverListFactory$Provider);

  final _ItemSliverListFactory$Provider _itemSliverListFactory$Provider;

  @override
  _i14.HomePageBody create({_i12.Key? key}) => _i14.HomePageBody(
        key: key,
        itemSliverListFactory: _itemSliverListFactory$Provider.get(),
      );
}

class _HomePageWithBlocFactory$Provider
    implements _i5.Provider<_i14.HomePageWithBlocFactory> {
  _HomePageWithBlocFactory$Provider(this._homePageBodyFactory$Provider);

  final _HomePageBodyFactory$Provider _homePageBodyFactory$Provider;

  late final _i14.HomePageWithBlocFactory _factory =
      _HomePageWithBlocFactory$Factory(_homePageBodyFactory$Provider);

  @override
  _i14.HomePageWithBlocFactory get() => _factory;
}

class _HomePageWithBlocFactory$Factory implements _i14.HomePageWithBlocFactory {
  const _HomePageWithBlocFactory$Factory(this._homePageBodyFactory$Provider);

  final _HomePageBodyFactory$Provider _homePageBodyFactory$Provider;

  @override
  _i14.HomePageWithBloc create({_i12.Key? key}) => _i14.HomePageWithBloc(
        key: key,
        homePageBodyFactory: _homePageBodyFactory$Provider.get(),
      );
}

class _MyAppFactory$Provider implements _i5.Provider<_i4.MyAppFactory> {
  _MyAppFactory$Provider(
    this._homePageWithBlocFactory$Provider,
    this._homePageBloc$Provider,
  );

  final _HomePageWithBlocFactory$Provider _homePageWithBlocFactory$Provider;

  final _HomePageBloc$Provider _homePageBloc$Provider;

  late final _i4.MyAppFactory _factory = _MyAppFactory$Factory(
    _homePageWithBlocFactory$Provider,
    _homePageBloc$Provider,
  );

  @override
  _i4.MyAppFactory get() => _factory;
}

class _MyAppFactory$Factory implements _i4.MyAppFactory {
  const _MyAppFactory$Factory(
    this._homePageWithBlocFactory$Provider,
    this._homePageBloc$Provider,
  );

  final _HomePageWithBlocFactory$Provider _homePageWithBlocFactory$Provider;

  final _HomePageBloc$Provider _homePageBloc$Provider;

  @override
  _i4.MyApp create({_i12.Key? key}) => _i4.MyApp(
        key: key,
        homePageFactory: _homePageWithBlocFactory$Provider.get(),
        homePageBlocProvider: _homePageBloc$Provider,
      );
}
