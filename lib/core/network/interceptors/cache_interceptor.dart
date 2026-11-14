import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:http_cache_file_store/http_cache_file_store.dart';
import 'package:path_provider/path_provider.dart';
import '../dio_client.dart';

Future<FileCacheStore> _createFileCacheStore() async {
  final cacheDir = await getApplicationCacheDirectory();
  return FileCacheStore(cacheDir.path);
}

/// Adds the HTTP cache. Requests that must skip it use [noHttpCacheOptions].
///
/// An online-only optimisation: it revalidates JSON and images while the
/// server answers, and never answers in place of an unreachable server
/// (`hitCacheOnNetworkFailure: false`). The offline source of truth is the
/// drift offline cache, so a connection error must reach the repository.
Future<void> setupCacheInterceptor(
  DioClient dioClient, {
  CacheStore? store,
}) async {
  final effectiveStore = store ?? await _createFileCacheStore();

  final cacheOptions = CacheOptions(
    store: effectiveStore,
    policy: CachePolicy.request,
    maxStale: const Duration(days: 7),
    priority: CachePriority.normal,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    allowPostMethod: false,
    hitCacheOnNetworkFailure: false,
  );

  dioClient.dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
}

/// Request options that bypass the HTTP cache: nothing is read from it or
/// written to it (the store here only receives the policy's no-op delete).
/// For requests whose answer must come from the network (the connectivity
/// probe) or that keep their own copy (the cover store).
Options noHttpCacheOptions() => CacheOptions(
  store: MemCacheStore(),
  policy: CachePolicy.noCache,
).toOptions();
