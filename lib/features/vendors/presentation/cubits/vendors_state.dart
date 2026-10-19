import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_vendors.dart';
import 'vendors_cubit.dart';

class VendorsCubit extends Cubit<VendorsState> {
  final GetVendorsUseCase getVendorsUseCase;

  VendorsCubit({required this.getVendorsUseCase}) : super(const VendorsState());

  void loadVendors() {
    emit(const VendorsState(status: VendorsStatus.loading));

    try {
      final vendors = getVendorsUseCase();

      emit(VendorsState(status: VendorsStatus.success, vendors: vendors));
    } catch (e) {
      emit(
        VendorsState(status: VendorsStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
