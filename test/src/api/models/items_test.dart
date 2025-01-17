import 'package:breuninger/src/api/models/items.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Items JSON parsing', () {
    test('successfully parses valid items list', () {
      final json = [
        {
          'id': 1,
          'type': 'teaser',
          'gender': 'male',
          'expires_at': '2025-01-20T10:00:00.000Z',
          'attributes': {
            'headline': 'new looks',
            'image_url': 'https://placecats.com/300/200',
            'url': 'https://www.breuninger.com/de/herren/',
          },
        },
        {
          'id': 2,
          'type': 'teaser',
          'gender': 'male',
          'gender': 'female',
          'expires_at': '2025-01-20T10:00:00.000Z',
          'attributes': {
            'headline': 'new looks',
            'image_url': 'https://placecats.com/300/200',
            'url': 'https://www.breuninger.com/de/herren/',
          },
        },
        {
          'id': 3,
          'type': 'slider',
          'attributes': {
            'items': [
              {
                'id': 2442,
                'gender': 'female',
                'expires_at': '2025-01-10T10:00:00.000Z',
                'headline': 'new collection',
                'image_url': 'https://placecats.com/300/200',
                'url': 'https://www.breuninger.com/de/damen/accessoires/',
              },
              {
                'id': 9685,
                'gender': 'male',
                'expires_at': '2024-12-25T00:00:00.000Z',
                'headline': '2025 styles',
                'image_url': 'https://placecats.com/300/200',
                'url': 'https://www.breuninger.com/de/damen/schuhe/',
              },
              {
                'id': 3344,
                'gender': 'female',
                'expires_at': '2025-01-12T10:00:00.000Z',
                'headline': 'new looks',
                'image_url': 'https://placecats.com/300/200',
                'url': 'https://www.breuninger.com/de/damen/luxus/',
              }
            ],
          },
        },
        {
          'id': 4,
          'type': 'brand_slider',
          'attributes': {
            'items_url':
                'https://gist.githubusercontent.com/breunibes/685504fa15950dea41be757f50f334a0/raw/a1fe57865871c08d7544e0bf1a89564fe698b42a/brand_items.json',
          },
        }
      ];

      final items = Items.fromJson(json);
      expect(items.items.length, 4);
      expect(items.items[0], isA<TeaserItem>());
      expect(items.items[1], isA<TeaserItem>());
      expect(items.items[2], isA<SliderItem>());
      expect(items.items[3], isA<BrandSliderItem>());
    });

    test('handles empty list', () {
      final items = Items.fromJson([]);
      expect(items.items, isEmpty);
    });

    test('skips invalid items but continues parsing', () {
      final json = [
        {
          'id': 1,
          'type': 'teaser',
          'gender': 'male',
          'expires_at': '2025-01-20T10:00:00.000Z',
          'attributes': {
            'headline': 'new looks',
            'image_url': 'https://placecats.com/300/200',
            'url': 'https://www.breuninger.com/de/herren/',
          },
        },
        {
          'id': 2,
          'type': 'teaser',
          'gender': 'male',
          'expires_at': '2025-01-20T10:00:00.000Z',
          'attributes': {
            'headline': 'new looks',
            'image_url': 'https://placecats.com/300/200',
            // missing url,
          },
        },
        {
          'id': 3,
          'type': 'teaser',
          'gender': 'female',
          'expires_at': 'invalid-date',
          'attributes': {
            'headline': 'new looks',
            'image_url': 'https://placecats.com/300/200',
            'url': 'https://www.breuninger.com/de/herren/',
          },
        },
        {
          'id': 4,
          'type': 'teaser',
          'gender': 'invalid',
          'expires_at': '2025-01-20T10:00:00.000Z',
          'attributes': {
            'headline': 'new looks',
            'image_url': 'https://placecats.com/300/200',
            'url': 'https://www.breuninger.com/de/herren/',
          },
        },
        {
          'id': 5,
          'type': 'teaser',
          'gender': 'female',
          'expires_at': '2025-01-20T10:00:00.000Z',
          'attributes': {
            'headline': 'new looks',
            'image_url': 'https://placecats.com/300/200',
            'url': 'https://www.breuninger.com/de/herren/',
          },
        },
      ];

      final items = Items.fromJson(json);
      expect(items.items.length, 2);
      expect(items.items[0], isA<TeaserItem>());
      expect(items.items[1], isA<TeaserItem>());
      expect((items.items[0] as TeaserItem).id, 1);
      expect((items.items[1] as TeaserItem).id, 5);
    });
  });

  group('TeaserItem parsing', () {
    test('successfully parses valid teaser', () {
      final json = {
        'id': 1,
        'type': 'teaser',
        'gender': 'male',
        'expires_at': '2025-01-20T10:00:00.000Z',
        'attributes': {
          'headline': 'new looks',
          'image_url': 'https://placecats.com/300/200',
          'url': 'https://www.breuninger.com/de/herren/',
        },
      };

      final teaser = TeaserItem.fromJson(json);
      expect(teaser.id, 1);
      expect(teaser.gender, Gender.male);
      expect(teaser.headline, 'new looks');
    });

    test('throws when mandatory field is missing', () {
      final json = {
        'id': 1,
        'type': 'teaser',
        'gender': 'male',
        // missing expires_at
        'attributes': {
          'headline': 'new looks',
          'image_url': 'https://placecats.com/300/200',
          'url': 'https://www.breuninger.com/de/herren/',
        },
      };

      expect(() => TeaserItem.fromJson(json), throwsFormatException);
    });
  });

  group('SliderItem parsing', () {
    test('successfully parses valid slider with items', () {
      final json = {
        'id': 3,
        'type': 'slider',
        'attributes': {
          'items': [
            {
              'id': 2442,
              'gender': 'female',
              'expires_at': '2025-01-10T10:00:00.000Z',
              'headline': 'new collection',
              'image_url': 'https://placecats.com/300/200',
              'url': 'https://www.breuninger.com/de/damen/accessoires/',
            }
          ],
        },
      };

      final slider = SliderItem.fromJson(json);
      expect(slider.id, 3);
      expect(slider.attributes.length, 1);
      expect(slider.attributes.first.id, 2442);
    });

    test('skips invalid slider attributes but continues parsing', () {
      final json = {
        'id': 3,
        'type': 'slider',
        'attributes': {
          'items': [
            {
              'id': 2442,
              'gender': 'female',
              'expires_at': '2025-01-10T10:00:00.000Z',
              'headline': 'new collection',
              'image_url': 'https://placecats.com/300/200',
              'url': 'https://www.breuninger.com/de/damen/accessoires/',
            },
            {
              'id': 9685,
              'gender': 'invalid_gender', // Invalid gender
              'expires_at': '2024-12-25T00:00:00.000Z',
              'headline': '2025 styles',
              'image_url': 'https://placecats.com/300/200',
              'url': 'https://www.breuninger.com/de/damen/schuhe/',
            },
            {
              'id': 3344,
              'gender': 'female',
              'expires_at': 'invalid_date', // Invalid date
              'headline': 'new looks',
              'image_url': 'https://placecats.com/300/200',
              'url': 'https://www.breuninger.com/de/damen/luxus/',
            },
            {
              'id': 5566,
              'gender': 'female',
              'expires_at': '2025-01-12T10:00:00.000Z',
              'headline': 'new looks',
              'image_url': 'https://placecats.com/300/200',
              'url': 'https://www.breuninger.com/de/damen/luxus/',
            }
          ],
        },
      };

      final slider = SliderItem.fromJson(json);
      expect(slider.id, 3);
      expect(slider.attributes.length, 2); // Only valid items remain
      expect(slider.attributes[0].id, 2442);
      expect(slider.attributes[1].id, 5566);
    });

    test('throws when items array is missing', () {
      final json = {
        'id': 3,
        'type': 'slider',
        'attributes': {},
      };

      expect(() => SliderItem.fromJson(json), throwsFormatException);
    });
  });

  group('BrandSliderItem parsing', () {
    test('successfully parses valid brand slider', () {
      final json = {
        'id': 4,
        'type': 'brand_slider',
        'attributes': {
          'items_url': 'https://example.com/brands',
        },
      };

      final brandSlider = BrandSliderItem.fromJson(json);
      expect(brandSlider.id, 4);
      expect(brandSlider.itemsUrl, 'https://example.com/brands');
    });

    test('throws when items_url is missing', () {
      final json = {
        'id': 4,
        'type': 'brand_slider',
        'attributes': {},
      };

      expect(() => BrandSliderItem.fromJson(json), throwsFormatException);
    });

    // Add this to the 'BrandSliderItem parsing' group:

    test('successfully parses brand items JSON response', () {
      final brandItemsJson = {
        'items': [
          {
            'id': 47567,
            'gender': 'female',
            'expires_at': '2025-02-10T10:00:00.000Z',
            'headline': 'brand item 1',
            'image_url': 'https://placecats.com/300/200',
            'url': 'https://www.breuninger.com/de/damen/accessoires/',
          },
          {
            'id': 465757,
            'gender': 'male',
            'expires_at': '2025-01-01T00:00:00.000Z',
            'headline': 'brand item 2',
            'image_url': 'https://placecats.com/300/200',
            'url': 'https://www.breuninger.com/de/damen/schuhe/',
          }
        ],
      };

      final items = brandItemsJson['items'] as List<dynamic>;
      final attributes = items.map((item) => SliderAttribute.fromJson(item)).toList();

      expect(attributes.length, 2);

      final firstItem = attributes[0];
      expect(firstItem.id, 47567);
      expect(firstItem.gender, Gender.female);
      expect(firstItem.headline, 'brand item 1');
      expect(firstItem.expiresAt, DateTime.parse('2025-02-10T10:00:00.000Z'));

      final secondItem = attributes[1];
      expect(secondItem.id, 465757);
      expect(secondItem.gender, Gender.male);
      expect(secondItem.headline, 'brand item 2');
      expect(secondItem.expiresAt, DateTime.parse('2025-01-01T00:00:00.000Z'));
    });

    test('handles invalid brand items in JSON response', () {
      final brandItemsJson = {
        'items': [
          {
            'id': 47567,
            'gender': 'female',
            'expires_at': '2025-02-10T10:00:00.000Z',
            'headline': 'brand item 1',
            'image_url': 'https://placecats.com/300/200',
            'url': 'https://www.breuninger.com/de/damen/accessoires/',
          },
          {
            // Missing required fields
            'id': 465757,
            'gender': 'male',
          }
        ],
      };

      final items = brandItemsJson['items'] as List<dynamic>;
      expect(
        () => items.map((item) => SliderAttribute.fromJson(item)).toList(),
        throwsFormatException,
      );
    });

    test('handles empty items array in brand items response', () {
      final brandItemsJson = {'items': []};

      final items = brandItemsJson['items'] as List<dynamic>;
      final attributes = items.map((item) => SliderAttribute.fromJson(item)).toList();

      expect(attributes, isEmpty);
    });
  });

  group('Edge cases', () {
    test('handles invalid date format', () {
      final json = {
        'id': 1,
        'type': 'teaser',
        'gender': 'male',
        'expires_at': 'invalid-date',
        'attributes': {
          'headline': 'new looks',
          'image_url': 'https://placecats.com/300/200',
          'url': 'https://www.breuninger.com/de/herren/',
        },
      };

      expect(() => TeaserItem.fromJson(json), throwsFormatException);
    });

    test('handles invalid gender value', () {
      final json = {
        'id': 1,
        'type': 'teaser',
        'gender': 'invalid',
        'expires_at': '2025-01-20T10:00:00.000Z',
        'attributes': {
          'headline': 'new looks',
          'image_url': 'https://placecats.com/300/200',
          'url': 'https://www.breuninger.com/de/herren/',
        },
      };

      expect(() => TeaserItem.fromJson(json), throwsA(isA<ArgumentError>()));
    });

    test('handles unknown item type', () {
      final json = {
        'id': 1,
        'type': 'unknown_type',
        'attributes': {},
      };

      expect(() => Item.fromJson(json), throwsFormatException);
    });
  });
}
