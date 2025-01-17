import 'package:flutter/material.dart';

class PlatformWidget extends StatelessWidget {
  const PlatformWidget({
    super.key,
    required WidgetBuilder cupertinoWidget,
    required WidgetBuilder materialWidget,
  })  : _cupertinoWidget = cupertinoWidget,
        _materialWidget = materialWidget;

  final WidgetBuilder _cupertinoWidget;
  final WidgetBuilder _materialWidget;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS ? _cupertinoWidget(context) : _materialWidget(context);
  }
}
