import '../../domain/entities/vendor_entity.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../datasources/vendor_local_datasource.dart';

class VendorRepositoryImpl implements VendorRepository {
  final VendorLocalDataSource localDataSource;

  const VendorRepositoryImpl({required this.localDataSource});

  @override
  List<VendorEntity> getVendors() {
    return localDataSource.getVendors();
  }
}
