class UserEntity {
  final String id;
  final String email;
  final String? displayName;
  final String? imagePath;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.imagePath,
  });
}
