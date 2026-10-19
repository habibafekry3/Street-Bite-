import '../entities/vendor_entity.dart';

abstract class VendorRepository {
  List<VendorEntity> getVendors();
}
