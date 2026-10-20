import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/datasources/availability_remote_data_source.dart';
import '../../data/repositories/availability_repository_impl.dart';
import '../../domain/entities/availability.dart';
import '../../domain/repositories/availability_repository.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(tokenStorage: ref.watch(tokenStorageProvider));
});

final availabilityRemoteDataSourceProvider =
    Provider<AvailabilityRemoteDataSource>((ref) {
      return AvailabilityRemoteDataSource(ref.watch(dioClientProvider).dio);
    });

final availabilityRepositoryProvider = Provider<AvailabilityRepository>((ref) {
  return AvailabilityRepositoryImpl(
    ref.watch(availabilityRemoteDataSourceProvider),
  );
});

// final doctorAvailabilityProvider = FutureProvider<List<Availability>>((ref) {
//   return ref.watch(availabilityRepositoryProvider).getAvailability();
// });
final doctorAvailabilityProvider = FutureProvider<List<Availability>>((
  ref,
) async {
  return ref
      .watch(availabilityRepositoryProvider)
      .getAvailability()
      .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception(
            'The server took too long to respond. '
            'Please check your connection and try again.',
          );
        },
      );
});
