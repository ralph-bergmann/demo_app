import 'package:bloc_test/bloc_test.dart';
import 'package:breuninger/src/api/api_repository.dart';
import 'package:breuninger/src/api/models/dataset.dart';
import 'package:breuninger/src/features/home_with_bloc/home_page_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_test_handler/shelf_test_handler.dart';

const _gistfile1 = '''
    [
      {
        "id": 1,
        "type": "teaser",
        "gender": "male",
        "expires_at": "2025-01-20T10:00:00.000Z",
        "attributes": {
          "headline": "new looks",
          "image_url": "https://placecats.com/300/200",
          "url": "https://www.breuninger.com/de/herren/"
        }
      },  
      {
        "id": 2,
        "type": "teaser",
        "gender": "male",
        "gender": "female",
        "expires_at": "2025-01-20T10:00:00.000Z",
        "attributes": {
          "headline": "new looks",
          "image_url": "https://placecats.com/300/200",
          "url": "https://www.breuninger.com/de/herren/"
        }
      },
      {
        "id": 3,
        "type": "slider",
        "attributes": {
          "items": [
            {
              "id": 2442,
              "gender": "female",
              "expires_at": "2025-01-10T10:00:00.000Z",
              "headline": "new collection",
              "image_url": "https://placecats.com/300/200",
              "url": "https://www.breuninger.com/de/damen/accessoires/"
            },
            {
              "id": 9685,
              "gender": "male",
              "expires_at": "2024-12-25T00:00:00.000Z",
              "headline": "2025 styles",
              "image_url": "https://placecats.com/300/200",
              "url": "https://www.breuninger.com/de/damen/schuhe/"
            },
            {
              "id": 3344,
              "gender": "female",
              "expires_at": "2025-01-12T10:00:00.000Z",
              "headline": "new looks",
              "image_url": "https://placecats.com/300/200",
              "url": "https://www.breuninger.com/de/damen/luxus/"
            }
          ]
        }
      },
      {
        "id": 4,
        "type": "brand_slider",
        "attributes": {
          "items_url": "https://gist.githubusercontent.com/breunibes/685504fa15950dea41be757f50f334a0/raw/a1fe57865871c08d7544e0bf1a89564fe698b42a/brand_items.json"
        }
      }
    ]
  ''';

const _mock = '''
    [
      {
        "id": 1,
        "type": "teaser",
        "gender": "male",
        "expires_at": "2025-01-20T10:00:00.000Z",
        "attributes": {
          "headline": "new looks",
          "image_url": "https://placecats.com/300/200",
          "url": "https://www.breuninger.com/de/herren/"
        }
      },  
      {
        "id": 2,
        "type": "teaser",
        "gender": "male",
        "gender": "female",
        "expires_at": "2025-01-20T10:00:00.000Z",
        "attributes": {
          "headline": "new looks",
          "image_url": "https://placecats.com/300/200",
          "url": "https://www.breuninger.com/de/herren/"
        }
      },
      {
        "id": 3,
        "type": "slider",
        "attributes": {
          "items": [
            {
              "id": 2442,
              "gender": "female",
              "expires_at": "2025-01-10T10:00:00.000Z",
              "headline": "new collection",
              "image_url": "https://placecats.com/300/200",
              "url": "https://www.breuninger.com/de/damen/accessoires/"
            },
            {
              "id": 9685,
              "gender": "male",
              "expires_at": "2024-12-25T00:00:00.000Z",
              "headline": "2025 styles",
              "image_url": "https://placecats.com/300/200",
              "url": "https://www.breuninger.com/de/damen/schuhe/"
            },
            {
              "id": 3344,
              "gender": "female",
              "expires_at": "2025-01-12T10:00:00.000Z",
              "headline": "new looks",
              "image_url": "https://placecats.com/300/200",
              "url": "https://www.breuninger.com/de/damen/luxus/"
            }
          ]
        }
      }
    ]
  ''';

void main() {
  ShelfTestServer? server;

  blocTest<HomePageBloc, HomePageState>(
    'loads dataset1 (mock) correctly',
    setUp: () async {
      server = await ShelfTestServer.create();
    },
    tearDown: () async {
      await server?.close();
    },
    build: () {
      server?.handler.expect(
        'GET',
        '/mock.json',
        (request) async => shelf.Response.ok(
          _mock,
          headers: {'content-type': 'application/json'},
        ),
      );

      final client = http.Client();
      final logger = Logger('test logger');
      final repository = ApiRepository(client: client, logger: logger);
      return HomePageBloc(repository: repository);
    },
    act: (bloc) => bloc.add(const LoadDataSetRequest()),
    wait: const Duration(seconds: 1), // wait until async request is done
    expect: () => [
      // test for initial state
      predicate<HomePageState>(
        (state) =>
            state.isLoading &&
            !state.hasLoadingError &&
            state.selectedDataSet == DataSet.dataSet1 &&
            state.items != null &&
            state.items!.isEmpty,
      ),
      // test state after LoadDataSetRequest is done
      predicate<HomePageState>(
        (state) =>
            !state.isLoading &&
            !state.hasLoadingError &&
            state.selectedDataSet == DataSet.dataSet1 &&
            state.items != null &&
            state.items!.length == 3,
      ),
    ],
  );

  blocTest<HomePageBloc, HomePageState>(
    'switches to dataset2 (gistfile1.json) and loads it correctly',
    setUp: () async {
      server = await ShelfTestServer.create();
    },
    tearDown: () async {
      await server?.close();
    },
    build: () {
      server?.handler.expect(
        'GET',
        '/dataset1.json',
        (request) async => shelf.Response.ok(
          _gistfile1,
          headers: {'content-type': 'application/json'},
        ),
      );

      final client = http.Client();
      final logger = Logger('test logger');
      final repository = ApiRepository(client: client, logger: logger);
      return HomePageBloc(repository: repository);
    },
    act: (bloc) => bloc.add(const SelectDataSet(DataSet.dataSet2)),
    wait: const Duration(seconds: 1), // wait until async request is done
    expect: () => [
      // test switch dataset
      predicate<HomePageState>(
        (state) =>
            !state.isLoading &&
            !state.hasLoadingError &&
            state.selectedDataSet == DataSet.dataSet2 &&
            state.items != null &&
            state.items!.isEmpty,
      ),
      // test loading dataset
      predicate<HomePageState>(
        (state) =>
            state.isLoading &&
            !state.hasLoadingError &&
            state.selectedDataSet == DataSet.dataSet2 &&
            state.items != null &&
            state.items!.isEmpty,
      ),
      // test state after LoadDataSetRequest is done
      predicate<HomePageState>(
        (state) =>
            !state.isLoading &&
            !state.hasLoadingError &&
            state.selectedDataSet == DataSet.dataSet2 &&
            state.items != null &&
            state.items!.length == 4,
      ),
    ],
  );
}
