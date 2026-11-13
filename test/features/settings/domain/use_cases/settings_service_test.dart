import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/app_theme_choice.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gatuno/features/settings/data/data_sources/settings_local_data_source.dart';
import 'package:gatuno/features/settings/domain/use_cases/settings_service.dart';
import 'package:gatuno/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class MockSettingsStorage extends Mock implements SettingsStorage {}

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late SettingsService settingsService;
  late MockSettingsStorage mockStorage;
  late MockDioClient mockDioClient;
  late MockDio mockDio;

  setUpAll(() => registerFallbackValue(AppThemeChoice.system));

  setUp(() {
    mockStorage = MockSettingsStorage();
    mockDioClient = MockDioClient();
    mockDio = MockDio();

    when(() => mockDioClient.dio).thenReturn(mockDio);
    when(() => mockDio.options).thenReturn(BaseOptions());

    settingsService = SettingsService(mockStorage, mockDioClient);
  });

  group('SettingsService', () {
    test('init should load saved settings', () async {
      when(
        () => mockStorage.getApiUrl(),
      ).thenAnswer((_) async => 'http://test.com');
      when(
        () => mockStorage.isSensitiveContentEnabled(),
      ).thenAnswer((_) async => true);
      when(
        () => mockStorage.getThemeChoice(),
      ).thenAnswer((_) async => AppThemeChoice.dracula);
      when(() => mockDioClient.updateBaseUrl(any())).thenAnswer((_) {});

      await settingsService.init();
      expect(settingsService.themeChoice, AppThemeChoice.dracula);

      expect(settingsService.apiUrl, 'http://test.com');
      expect(settingsService.sensitiveContentEnabled, isTrue);
      expect(settingsService.isInitialized, isTrue);
      verify(() => mockDioClient.updateBaseUrl('http://test.com')).called(1);
    });

    test('setThemeChoice should update storage and state', () async {
      when(() => mockStorage.setThemeChoice(any())).thenAnswer((_) async {});

      await settingsService.setThemeChoice(AppThemeChoice.slate);

      expect(settingsService.themeChoice, AppThemeChoice.slate);
      verify(() => mockStorage.setThemeChoice(AppThemeChoice.slate)).called(1);
    });

    test('setApiUrl should update storage and dio client', () async {
      when(() => mockStorage.setApiUrl(any())).thenAnswer((_) async {});
      when(() => mockDioClient.updateBaseUrl(any())).thenAnswer((_) {});

      await settingsService.setApiUrl('http://new.com');

      expect(settingsService.apiUrl, 'http://new.com');
      verify(() => mockStorage.setApiUrl('http://new.com')).called(1);
      verify(() => mockDioClient.updateBaseUrl('http://new.com')).called(1);
    });

    group('server change', () {
      late int wipes;

      setUp(() {
        wipes = 0;
        settingsService = SettingsService(
          mockStorage,
          mockDioClient,
          onServerChanged: () async => wipes++,
        );
        when(() => mockStorage.setApiUrl(any())).thenAnswer((_) async {});
        when(() => mockDioClient.updateBaseUrl(any())).thenAnswer((_) {});
      });

      test('the first URL wipes nothing', () async {
        await settingsService.setApiUrl('http://a.com');
        expect(wipes, 0);
      });

      test('a different server wipes the offline cache', () async {
        await settingsService.setApiUrl('http://a.com');
        await settingsService.setApiUrl('http://b.com');
        expect(wipes, 1);
      });

      test('the wipe runs after the switch to the new server', () async {
        final order = <String>[];
        when(() => mockDioClient.updateBaseUrl(any())).thenAnswer((inv) {
          order.add('switch ${inv.positionalArguments.first}');
        });
        settingsService = SettingsService(
          mockStorage,
          mockDioClient,
          onServerChanged: () async => order.add('wipe'),
        );

        await settingsService.setApiUrl('http://a.com');
        await settingsService.setApiUrl('http://b.com');

        expect(order, ['switch http://a.com', 'switch http://b.com', 'wipe']);
      });

      test('the same server (trailing slash aside) wipes nothing', () async {
        await settingsService.setApiUrl('http://a.com');
        await settingsService.setApiUrl('http://a.com/');
        expect(wipes, 0);
      });

      test('a failed wipe does not block the switch', () async {
        settingsService = SettingsService(
          mockStorage,
          mockDioClient,
          onServerChanged: () async => throw StateError('disk'),
        );
        await settingsService.setApiUrl('http://a.com');
        await settingsService.setApiUrl('http://b.com');

        expect(settingsService.apiUrl, 'http://b.com');
      });
    });

    test('setSensitiveContentEnabled should update storage', () async {
      when(
        () => mockStorage.setSensitiveContentEnabled(any()),
      ).thenAnswer((_) async {});

      await settingsService.setSensitiveContentEnabled(true);

      expect(settingsService.sensitiveContentEnabled, isTrue);
      verify(() => mockStorage.setSensitiveContentEnabled(true)).called(1);
    });

    test('init should handle errors gracefully', () async {
      when(() => mockStorage.getApiUrl()).thenThrow(Exception('Storage error'));

      await settingsService.init();

      expect(settingsService.isInitialized, isFalse);
    });

    group('validateApiUrl', () {
      test('should return true when health check returns 200', () async {
        final response = Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        );
        when(
          () => mockDio.get<Map<String, dynamic>>(any()),
        ).thenAnswer((_) async => response);

        final result = await settingsService.validateApiUrl('http://test.com');

        expect(result, isTrue);
        verify(
          () => mockDio.get<Map<String, dynamic>>(
            'http://test.com/health/liveness',
          ),
        ).called(1);
      });

      test('should return false when health check returns non-200', () async {
        final response = Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
        );
        when(
          () => mockDio.get<Map<String, dynamic>>(any()),
        ).thenAnswer((_) async => response);

        final result = await settingsService.validateApiUrl('http://test.com');

        expect(result, isFalse);
      });

      test('should return false when dio throws exception', () async {
        when(
          () => mockDio.get<Map<String, dynamic>>(any()),
        ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        final result = await settingsService.validateApiUrl('http://test.com');

        expect(result, isFalse);
      });
    });
  });
}
