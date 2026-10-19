import '../entities/vendor_entity.dart';
import '../repositories/vendor_repository.dart';

class GetVendorsUseCase {
  final VendorRepository repository;

  const GetVendorsUseCase({required this.repository});

  List<VendorEntity> call() {
    return repository.getVendors();
  }
}
