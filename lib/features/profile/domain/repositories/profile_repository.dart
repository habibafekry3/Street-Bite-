abstract class ProfileRepository {
  Future<Map<String, dynamic>?> getProfile();

  Future<void> updateProfileName(String name);

  Future<void> updateProfileImage(String imageBase64);
}
