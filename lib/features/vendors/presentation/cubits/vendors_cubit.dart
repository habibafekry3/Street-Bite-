import '../../domain/entities/vendor_entity.dart';

enum VendorsStatus { initial, loading, success, failure }

class VendorsState {
  final VendorsStatus status;
  final List<VendorEntity> vendors;
  final String? errorMessage;

  const VendorsState({
    this.status = VendorsStatus.initial,
    this.vendors = const [],
    this.errorMessage,
  });
}
