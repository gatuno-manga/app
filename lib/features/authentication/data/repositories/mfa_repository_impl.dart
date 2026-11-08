import 'package:dio/dio.dart';
import '../../../../core/logging/logger.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/exceptions.dart';
import '../../domain/repositories/mfa_repository.dart';
import '../../domain/value_objects/mfa_models.dart';

class MfaRepositoryImpl implements MfaRepository {
  final Dio _dio;
  static const String _logTag = 'MfaRepository';

  MfaRepositoryImpl(this._dio);

  @override
  Future<MfaStatus> status() => _call(
    'status',
    () => _dio.get<Map<String, dynamic>>(ApiConstants.mfaStatus),
    MfaStatus.fromJson,
  );

  @override
  Future<TotpSetup> setupTotp() => _call(
    'setup',
    () => _dio.post<Map<String, dynamic>>(ApiConstants.mfaTotpSetup),
    TotpSetup.fromJson,
  );

  @override
  Future<BackupCodes> verifyTotpSetup(String code) => _call(
    'verify-setup',
    () => _dio.post<Map<String, dynamic>>(
      ApiConstants.mfaTotpVerifySetup,
      data: {'code': code},
    ),
    BackupCodes.fromJson,
  );

  @override
  Future<void> disableTotp(String code) => _call(
    'disable',
    () => _dio.post<Map<String, dynamic>>(
      ApiConstants.mfaTotpDisable,
      data: {'code': code},
    ),
    (_) {},
  );

  Future<T> _call<T>(
    String op,
    Future<Response<Map<String, dynamic>>> Function() request,
    T Function(Map<String, dynamic>) parse,
  ) async {
    try {
      final response = await request();
      final data = response.data;
      final ok = response.statusCode == 200 || response.statusCode == 201;
      if (!ok || data is! Map<String, dynamic>) {
        throw ServerException(
          message: 'MFA $op failed: invalid response',
          statusCode: response.statusCode,
        );
      }
      return parse(data);
    } on DioException catch (e) {
      AppLogger.w('MFA $op failed: ${e.message}', _logTag);
      throw ApiExceptionHandler.handle(e);
    } on AppExceptions {
      rethrow;
    } on FormatException catch (e) {
      throw ServerException(message: e.message);
    } catch (e, stackTrace) {
      AppLogger.e('MFA $op unexpected error', e, stackTrace, _logTag);
      throw AuthException('An unexpected error occurred during MFA $op');
    }
  }
}
