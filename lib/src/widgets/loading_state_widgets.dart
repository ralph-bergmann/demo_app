import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(
            Icons.sentiment_very_satisfied,
            size: 75,
            color: Colors.green[900],
          ),
          Text(AppLocalizations.of(context).loading_data),
        ],
      );
}

class ErrorWidget extends StatelessWidget {
  const ErrorWidget({super.key});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(
            Icons.sentiment_very_dissatisfied,
            size: 75,
            color: Colors.red[900],
          ),
          Text(AppLocalizations.of(context).error_while_loading_data),
        ],
      );
}
