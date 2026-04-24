import 'package:flutter_test/flutter_test.dart';
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
        () => mockStorage.getAllowedBadCertificateUrls(),
      ).thenAnswer((_) async => ['https://storage.com']);
      when(() => mockDioClient.updateBaseUrl(any())).thenAnswer((_) {});
      when(
        () => mockDioClient.updateAllowedBadCertificateUrls(any()),
      ).thenAnswer((_) {});

      await settingsService.init();

      expect(settingsService.apiUrl, 'http://test.com');
      expect(settingsService.sensitiveContentEnabled, isTrue);
      expect(settingsService.allowedBadCertificateUrls, ['https://storage.com']);
      expect(settingsService.isInitialized, isTrue);
      verify(() => mockDioClient.updateBaseUrl('http://test.com')).called(1);
      verify(
        () => mockDioClient.updateAllowedBadCertificateUrls(['https://storage.com']),
      ).called(1);
    });

    test('setApiUrl should update storage and dio client', () async {
      when(() => mockStorage.setApiUrl(any())).thenAnswer((_) async {});
      when(() => mockDioClient.updateBaseUrl(any())).thenAnswer((_) {});

      await settingsService.setApiUrl('http://new.com');

      expect(settingsService.apiUrl, 'http://new.com');
      verify(() => mockStorage.setApiUrl('http://new.com')).called(1);
      verify(() => mockDioClient.updateBaseUrl('http://new.com')).called(1);
    });

    test('setSensitiveContentEnabled should update storage', () async {
      when(
        () => mockStorage.setSensitiveContentEnabled(any()),
      ).thenAnswer((_) async {});

      await settingsService.setSensitiveContentEnabled(true);

      expect(settingsService.sensitiveContentEnabled, isTrue);
      verify(() => mockStorage.setSensitiveContentEnabled(true)).called(1);
    });

    test('addAllowedBadCertificateUrl should update storage and dio client', () async {
      when(
        () => mockStorage.setAllowedBadCertificateUrls(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockDioClient.updateAllowedBadCertificateUrls(any()),
      ).thenAnswer((_) {});

      await settingsService.addAllowedBadCertificateUrl('https://new-storage.com');

      expect(settingsService.allowedBadCertificateUrls, ['https://new-storage.com']);
      verify(
        () => mockStorage.setAllowedBadCertificateUrls(['https://new-storage.com']),
      ).called(1);
      verify(
        () => mockDioClient.updateAllowedBadCertificateUrls(['https://new-storage.com']),
      ).called(1);
    });

    test('removeAllowedBadCertificateUrl should update storage and dio client', () async {
      when(
        () => mockStorage.setAllowedBadCertificateUrls(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockDioClient.updateAllowedBadCertificateUrls(any()),
      ).thenAnswer((_) {});

      // Add one first
      await settingsService.addAllowedBadCertificateUrl('https://to-remove.com');
      
      await settingsService.removeAllowedBadCertificateUrl('https://to-remove.com');

      expect(settingsService.allowedBadCertificateUrls, isEmpty);
      verify(
        () => mockStorage.setAllowedBadCertificateUrls(any()),
      ).called(2);
      verify(
        () => mockDioClient.updateAllowedBadCertificateUrls(any()),
      ).called(2);
    });

    test('init should handle errors gracefully', () async {
      when(() => mockStorage.getApiUrl()).thenThrow(Exception('Storage error'));

      await settingsService.init();

      expect(settingsService.isInitialized, isFalse);
    });

    group('Edge Cases', () {
      test('addAllowedBadCertificateUrl should ignore empty or duplicate URL', () async {
        await settingsService.addAllowedBadCertificateUrl('');
        expect(settingsService.allowedBadCertificateUrls, isEmpty);

        when(() => mockStorage.setAllowedBadCertificateUrls(any())).thenAnswer((_) async {});
        when(() => mockDioClient.updateAllowedBadCertificateUrls(any())).thenAnswer((_) {});

        await settingsService.addAllowedBadCertificateUrl('https://test.com');
        await settingsService.addAllowedBadCertificateUrl('https://test.com');
        expect(settingsService.allowedBadCertificateUrls, ['https://test.com']);
      });
    });
  });
}
