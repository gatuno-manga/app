import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';

import 'data/data_sources/app_lock_local_data_source.dart';
import 'data/local_auth_device_authenticator.dart';
import 'data/method_channel_privacy_screen.dart';
import 'domain/device_authenticator.dart';
import 'domain/privacy_screen.dart';
import 'domain/use_cases/app_lock_service.dart';

void initAppLockInjection(GetIt sl) {
  sl.registerLazySingleton<AppLockStorage>(() => AppLockStorage());
  sl.registerLazySingleton<DeviceAuthenticator>(
    () => LocalAuthDeviceAuthenticator(LocalAuthentication()),
  );
  sl.registerLazySingleton<PrivacyScreen>(() => MethodChannelPrivacyScreen());
  sl.registerLazySingleton<AppLockService>(
    () => AppLockService(
      storage: sl<AppLockStorage>(),
      authenticator: sl<DeviceAuthenticator>(),
      privacyScreen: sl<PrivacyScreen>(),
    ),
  );
}
