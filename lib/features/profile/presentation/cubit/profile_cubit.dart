import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_name_usecase.dart';
import '../../domain/usecases/update_profile_image_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileNameUseCase updateProfileNameUseCase,
    required UpdateProfileImageUseCase updateProfileImageUseCase,
  }) : _getProfileUseCase = getProfileUseCase,
       _updateProfileNameUseCase = updateProfileNameUseCase,
       _updateProfileImageUseCase = updateProfileImageUseCase,
       super(const ProfileState());

  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileNameUseCase _updateProfileNameUseCase;
  final UpdateProfileImageUseCase _updateProfileImageUseCase;

  final ImagePicker _picker = ImagePicker();

  Future<void> loadSavedImage() async {
    emit(
      ProfileState(
        imagePath: state.imagePath,
        profileImageBase64: state.profileImageBase64,
        displayName: state.displayName,
        isLoading: true,
      ),
    );

    try {
      final profile = await _getProfileUseCase();

      emit(
        ProfileState(
          imagePath: state.imagePath,
          profileImageBase64: profile?['profileImageBase64'] as String?,
          displayName: profile?['displayName'] as String?,
        ),
      );
    } catch (_) {
      emit(
        ProfileState(
          imagePath: state.imagePath,
          profileImageBase64: state.profileImageBase64,
          displayName: state.displayName,
          errorMessage: 'profileLoadFailed',
        ),
      );
    }
  }

  Future<void> pickProfileImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 45,
      );

      if (image == null) return;

      emit(
        ProfileState(
          imagePath: state.imagePath,
          profileImageBase64: state.profileImageBase64,
          displayName: state.displayName,
          isLoading: true,
        ),
      );

      final compressedBytes = await FlutterImageCompress.compressWithFile(
        image.path,
        minWidth: 400,
        minHeight: 400,
        quality: 35,
      );

      if (compressedBytes == null || compressedBytes.isEmpty) {
        throw Exception('Image compression failed');
      }

      final encodedImage = base64Encode(compressedBytes);

      if (encodedImage.length > 700 * 1024) {
        throw Exception('Image is too large');
      }

      await _updateProfileImageUseCase(encodedImage);

      emit(
        ProfileState(
          imagePath: state.imagePath,
          profileImageBase64: encodedImage,
          displayName: state.displayName,
          successMessage: 'profileImageUpdated',
        ),
      );
    } catch (_) {
      emit(
        ProfileState(
          imagePath: state.imagePath,
          profileImageBase64: state.profileImageBase64,
          displayName: state.displayName,
          errorMessage: 'profileImageUploadFailed',
        ),
      );
    }
  }

  Future<void> updateProfileName(String name) async {
    final trimmedName = name.trim();

    emit(
      ProfileState(
        imagePath: state.imagePath,
        profileImageBase64: state.profileImageBase64,
        displayName: state.displayName,
        isLoading: true,
      ),
    );

    try {
      await _updateProfileNameUseCase(trimmedName);

      emit(
        ProfileState(
          imagePath: state.imagePath,
          profileImageBase64: state.profileImageBase64,
          displayName: trimmedName,
          successMessage: 'profileUpdated',
        ),
      );
    } catch (_) {
      emit(
        ProfileState(
          imagePath: state.imagePath,
          profileImageBase64: state.profileImageBase64,
          displayName: state.displayName,
          errorMessage: 'profileUpdateFailed',
        ),
      );
    }
  }
}
