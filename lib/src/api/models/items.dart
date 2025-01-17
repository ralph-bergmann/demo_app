import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../utils/logger.dart';

// it is easier to create a new logger than injecting one
final _logger = Logger(loggerName);

class Items {
  factory Items.fromJson(List<dynamic> json) {
    final items = json
        .whereType<Map<String, dynamic>>()
        .map((item) {
          try {
            return Item.fromJson(item);
          } catch (e, s) {
            _logger.warning('Failed to parse Item JSON', e, s);
            return null;
          }
        })
        .whereType<Item>()
        .toList();
    return Items._(items: items);
  }

  const Items._({
    required this.items,
  });

  final List<Item> items;
}

sealed class Item {
  factory Item.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    return switch (type) {
      TeaserItem.type => TeaserItem.fromJson(json),
      SliderItem.type => SliderItem.fromJson(json),
      BrandSliderItem.type => BrandSliderItem.fromJson(json),
      _ => throw FormatException('Item type ($type) not supported'),
    };
  }

  const Item();
}

enum Gender { all, male, female }

class TeaserItem extends Item {
  factory TeaserItem.fromJson(Map<String, dynamic> json) => switch (json) {
        {
          'id': final int id,
          'gender': final String gender,
          'expires_at': final String expiresAt,
          'attributes': {
            'headline': final String headline,
            'image_url': final String imageUrl,
            'url': final String url,
          },
        } =>
          TeaserItem(
            id: id,
            gender: Gender.values.byName(gender),
            expiresAt: DateTime.parse(expiresAt),
            headline: headline,
            imageUrl: imageUrl,
            url: url,
          ),
        _ => throw const FormatException('Failed to parse TeaserItem json.'),
      };

  const TeaserItem({
    required this.id,
    required this.gender,
    required this.expiresAt,
    required this.headline,
    required this.imageUrl,
    required this.url,
  });

  static const type = 'teaser';

  final int id;
  final Gender gender;
  final DateTime expiresAt;
  final String headline;
  final String imageUrl;
  final String url;

  @override
  String toString() => 'TeaserItem id: $id - gender: $gender - headline: $headline';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeaserItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          gender == other.gender &&
          expiresAt == other.expiresAt;

  @override
  int get hashCode => id.hashCode ^ gender.hashCode ^ expiresAt.hashCode;
}

class SliderItem extends Item {
  factory SliderItem.fromJson(Map<String, dynamic> json) => switch (json) {
        {
          'id': final int id,
          'attributes': {
            'items': final List<dynamic> attributes,
          },
        } =>
          SliderItem(
            id: id,
            attributes: attributes
                .whereType<Map<String, dynamic>>()
                .map((attribute) {
                  try {
                    return SliderAttribute.fromJson(attribute);
                  } catch (e, s) {
                    _logger.warning('Failed to parse SliderAttribute JSON', e, s);
                    return null;
                  }
                })
                .whereType<SliderAttribute>()
                .toList(),
          ),
        _ => throw const FormatException('Failed to parse SliderItem json.'),
      };

  const SliderItem({
    required this.id,
    required this.attributes,
  });

  static const type = 'slider';

  final int id;
  final List<SliderAttribute> attributes;

  @override
  String toString() => 'SliderItem id: $id - attributs count: ${attributes.length}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SliderItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          listEquals(attributes, other.attributes);

  @override
  int get hashCode => id.hashCode ^ Object.hashAll(attributes);
}

class SliderAttribute {
  factory SliderAttribute.fromJson(Map<String, dynamic> json) => switch (json) {
        {
          'id': final int id,
          'gender': final String gender,
          'expires_at': final String expiresAt,
          'headline': final String headline,
          'image_url': final String imageUrl,
          'url': final String url,
        } =>
          SliderAttribute(
            id: id,
            gender: Gender.values.byName(gender),
            expiresAt: DateTime.parse(expiresAt),
            headline: headline,
            imageUrl: imageUrl,
            url: url,
          ),
        _ => throw const FormatException('Failed to parse SliderItemContent json.'),
      };

  const SliderAttribute({
    required this.id,
    required this.gender,
    required this.expiresAt,
    required this.headline,
    required this.imageUrl,
    required this.url,
  });

  final int id;
  final Gender gender;
  final DateTime expiresAt;
  final String headline;
  final String imageUrl;
  final String url;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SliderAttribute &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          gender == other.gender &&
          expiresAt == other.expiresAt &&
          headline == other.headline &&
          imageUrl == other.imageUrl &&
          url == other.url;

  @override
  int get hashCode =>
      id.hashCode ^
      gender.hashCode ^
      expiresAt.hashCode ^
      headline.hashCode ^
      imageUrl.hashCode ^
      url.hashCode;
}

class BrandSliderItem extends Item {
  factory BrandSliderItem.fromJson(Map<String, dynamic> json) => switch (json) {
        {
          'id': final int id,
          'attributes': {
            'items_url': final String itemsUrl,
          },
        } =>
          BrandSliderItem(
            id: id,
            itemsUrl: itemsUrl,
          ),
        _ => throw const FormatException('Failed to parse BrandSliderItem json.'),
      };

  const BrandSliderItem({
    required this.id,
    required this.itemsUrl,
  });

  static const type = 'brand_slider';

  final int id;
  final String itemsUrl;

  @override
  String toString() => 'BrandSliderItem{id: $id, itemsUrl: $itemsUrl}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrandSliderItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          itemsUrl == other.itemsUrl;

  @override
  int get hashCode => id.hashCode ^ itemsUrl.hashCode;
}

class BrandItems {
  factory BrandItems.fromJson(Map<String, dynamic> json) => switch (json) {
        {
          'items': final List<dynamic> items,
        } =>
          BrandItems._(
            items: items
                .whereType<Map<String, dynamic>>()
                .map((item) {
                  try {
                    return SliderAttribute.fromJson(item);
                  } catch (e, s) {
                    _logger.warning('Failed to parse SliderAttribute JSON', e, s);
                    return null;
                  }
                })
                .whereType<SliderAttribute>()
                .toList(),
          ),
        _ => throw const FormatException('Failed to parse BrandItems json.'),
      };

  const BrandItems._({
    required this.items,
  });

  final List<SliderAttribute> items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrandItems && runtimeType == other.runtimeType && listEquals(items, other.items);

  @override
  int get hashCode => Object.hashAll(items);
}
