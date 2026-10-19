import '../models/vendor_model.dart';

class VendorLocalDataSource {
  const VendorLocalDataSource();

  List<VendorModel> getVendors() {
    return const [
      VendorModel(
        id: '1',
        nameKey: 'vendorCairoName',
        cuisineKey: 'vendorCairoCuisine',
        rating: 4.8,
        latitude: 30.0444,
        longitude: 31.2357,
      ),
      VendorModel(
        id: '2',
        nameKey: 'vendorAlexName',
        cuisineKey: 'vendorAlexCuisine',
        rating: 4.7,
        latitude: 31.2001,
        longitude: 29.9187,
      ),
      VendorModel(
        id: '3',
        nameKey: 'vendorLuxorName',
        cuisineKey: 'vendorLuxorCuisine',
        rating: 4.5,
        latitude: 25.6872,
        longitude: 32.6396,
      ),
      VendorModel(
        id: '4',
        nameKey: 'vendorAswanName',
        cuisineKey: 'vendorAswanCuisine',
        rating: 4.6,
        latitude: 24.0889,
        longitude: 32.8998,
      ),
      VendorModel(
        id: '5',
        nameKey: 'vendorMansouraName',
        cuisineKey: 'vendorMansouraCuisine',
        rating: 4.4,
        latitude: 31.0409,
        longitude: 31.3785,
      ),
    ];
  }
}
