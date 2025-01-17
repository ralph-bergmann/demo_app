import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inject_annotation/inject_annotation.dart';

import '../../localization/app_localizations.dart';
import '../../widgets/item_widgets.dart';
import '../../widgets/platform_widget.dart';
import '../home_with_bloc/home_page_bloc.dart';
import '../home_with_bloc/home_page_with_bloc.dart';

@assistedFactory
abstract class MyAppFactory {
  MyApp create({Key? key});
}

class MyApp extends StatelessWidget {
  @assistedInject
  const MyApp({
    @assisted super.key,
    // required HomePageFactory homePageFactory,
    required HomePageWithBlocFactory homePageFactory,
    required this.homePageBlocProvider,
  }) : _homePageFactory = homePageFactory;

  // my inital implementation with a [ChanngeNotifier]
  // final HomePageFactory _homePageFactory;

  // my implementation with a [BLoC]
  final HomePageWithBlocFactory _homePageFactory;
  final Provider<HomePageBloc> homePageBlocProvider;

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final themeExtensions = <ThemeExtension>[
      ItemWidgetTheme(
        headlineTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: brightness == Brightness.light
              ? Colors.black.withAlpha(200)
              : Colors.white.withAlpha(200),
        ),
      ),
    ];

    final theme = FlexThemeData.light(
      scheme: FlexScheme.red,
      extensions: themeExtensions,
    );
    final darkTheme = FlexThemeData.dark(
      scheme: FlexScheme.red,
      extensions: themeExtensions,
    );
    return BlocProvider(
      create: (context) => homePageBlocProvider.get(),
      child: PlatformWidget(
        cupertinoWidget: (context) => Theme(
          data: brightness == Brightness.light ? theme : darkTheme,
          child: CupertinoApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            home: _homePageFactory.create(),
          ),
        ),
        materialWidget: (context) => MaterialApp(
          theme: theme,
          darkTheme: darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          home: _homePageFactory.create(),
        ),
      ),
    );
  }
}
