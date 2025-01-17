import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/models/items.dart';
import '../localization/app_localizations.dart';
import '../widgets/platform_widget.dart';

class GenderFilterWidget extends StatelessWidget {
  const GenderFilterWidget({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
  });
  final Gender selectedGender;
  final ValueChanged<Gender?> onGenderSelected;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: PlatformWidget(
            materialWidget: (context) => SegmentedButton<Gender>(
              segments: [
                ...Gender.values.map(
                  (gender) => ButtonSegment<Gender>(
                    value: gender,
                    label: Text(AppLocalizations.of(context).greeting(gender: gender.name)),
                  ),
                ),
              ],
              selected: {selectedGender},
              onSelectionChanged: (selected) {
                onGenderSelected(selected.first);
              },
            ),
            cupertinoWidget: (context) => CupertinoSegmentedControl<Gender>(
              children: {
                ...Map.fromEntries(
                  Gender.values.map(
                    (gender) => MapEntry(
                      gender,
                      Text(AppLocalizations.of(context).greeting(gender: gender.name)),
                    ),
                  ),
                ),
              },
              groupValue: selectedGender,
              onValueChanged: onGenderSelected,
            ),
          ),
        ),
      );
}
