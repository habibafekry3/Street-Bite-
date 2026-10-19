import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/dependency_injection/injection.dart';
import '../cubits/vendors_cubit.dart';
import '../cubits/vendors_state.dart';

class NearbyVendorsScreen extends StatelessWidget {
  const NearbyVendorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VendorsCubit>()..loadVendors(),
      child: const _NearbyVendorsView(),
    );
  }
}

class _NearbyVendorsView extends StatelessWidget {
  const _NearbyVendorsView();
  static const LatLng _initialPosition = LatLng(26.8206, 30.8025);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('nearbyVendorsTitle'.tr())),
      body: BlocBuilder<VendorsCubit, VendorsState>(
        builder: (context, state) {
          if (state.status == VendorsStatus.loading ||
              state.status == VendorsStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == VendorsStatus.failure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    state.errorMessage ?? 'vendorsLoadError'.tr(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<VendorsCubit>().loadVendors();
                    },
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            );
          }

          final markers = state.vendors.map((vendor) {
            return Marker(
              markerId: MarkerId(vendor.id),
              position: LatLng(vendor.latitude, vendor.longitude),
              infoWindow: InfoWindow(
                title: vendor.nameKey.tr(),
                snippet: '${vendor.cuisineKey.tr()} • ${vendor.rating} ★',
              ),
            );
          }).toSet();

          return GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _initialPosition,
              zoom: 5.5,
            ),
            markers: markers,
            mapType: MapType.normal,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
          );
        },
      ),
    );
  }
}
