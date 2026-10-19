import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl({required ProfileRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Map<String, dynamic>?> getProfile() {
    return _remoteDataSource.getProfile();
  }

  @override
  Future<void> updateProfileName(String name) {
    return _remoteDataSource.updateProfileName(name);
  }

  @override
  Future<void> updateProfileImage(String imageBase64) {
    return _remoteDataSource.updateProfileImage(imageBase64);
  }
}
