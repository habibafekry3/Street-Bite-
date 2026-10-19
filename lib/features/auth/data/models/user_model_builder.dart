import 'user_model.dart';

class UserModelBuilder {
  String? _id;
  String? _email;
  String? _displayName;
  String? _imagePath;

  UserModelBuilder setId(String value) {
    _id = value;
    return this;
  }

  UserModelBuilder setEmail(String value) {
    _email = value;
    return this;
  }

  UserModelBuilder setDisplayName(String? value) {
    _displayName = value;
    return this;
  }

  UserModelBuilder setImagePath(String? value) {
    _imagePath = value;
    return this;
  }

  UserModel build() {
    if (_id == null || _email == null) {
      throw StateError('User id and email are required');
    }

    return UserModel(
      id: _id!,
      email: _email!,
      displayName: _displayName,
      imagePath: _imagePath,
    );
  }
}
