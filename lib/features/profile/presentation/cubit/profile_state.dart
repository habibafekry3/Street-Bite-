class ProfileState {
  final String? imagePath;
  final String? profileImageBase64;
  final String? displayName;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const ProfileState({
    this.imagePath,
    this.profileImageBase64,
    this.displayName,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });
}
