import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../injection_container.dart';
import '../../../services/shipping/rajaongkir_api.dart';
import '../../bloc/shipping/shipping_bloc.dart';
import '../../bloc/shipping/shipping_event.dart';
import '../../bloc/shipping/shipping_state.dart';
import '../../widgets/common/loading_widget.dart';

class ShippingCalculatorScreen extends StatelessWidget {
  const ShippingCalculatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ShippingBloc>()..add(const LoadCitiesRequested()),
      child: const _ShippingCalculatorView(),
    );
  }
}

class _ShippingCalculatorView extends StatefulWidget {
  const _ShippingCalculatorView({Key? key}) : super(key: key);

  @override
  State<_ShippingCalculatorView> createState() => _ShippingCalculatorViewState();
}

class _ShippingCalculatorViewState extends State<_ShippingCalculatorView> {
  final _weightController = TextEditingController(text: '1.0');
  bool _showOriginDropdown = false;
  bool _showDestinationDropdown = false;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Hitung Ongkir',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<ShippingBloc, ShippingState>(
        listener: (context, state) {
          if (state is ShippingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is ShippingTextCopied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        child: BlocBuilder<ShippingBloc, ShippingState>(
          builder: (context, state) {
            if (state is ShippingLoading) {
              return const LoadingWidget();
            }

            if (state is ShippingError && state.cities == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.w,
                      color: AppColors.error,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Gagal memuat data',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ShippingBloc>().add(const LoadCitiesRequested());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormSection(context, state),
                  SizedBox(height: 24.h),
                  _buildResultsSection(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormSection(BuildContext context, ShippingState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Pengiriman',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            _buildOriginCityField(context, state),
            SizedBox(height: 16.h),
            _buildDestinationCityField(context, state),
            SizedBox(height: 16.h),
            _buildWeightField(context, state),
            SizedBox(height: 24.h),
            _buildCalculateButton(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildOriginCityField(BuildContext context, ShippingState state) {
    final selectedOriginName = _getSelectedOriginName(state);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kota Asal',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          decoration: InputDecoration(
            hintText: selectedOriginName ?? 'Cari kota asal...',
            prefixIcon: const Icon(Icons.location_on_outlined),
            suffixIcon: IconButton(
              icon: Icon(_showOriginDropdown ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _showOriginDropdown = !_showOriginDropdown;
                  _showDestinationDropdown = false;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _showOriginDropdown = true;
              _showDestinationDropdown = false;
            });
            context.read<ShippingBloc>().add(SearchCitiesRequested(value));
          },
          onTap: () {
            setState(() {
              _showOriginDropdown = true;
              _showDestinationDropdown = false;
            });
          },
        ),
        if (_showOriginDropdown) _buildCityDropdown(context, state, true),
      ],
    );
  }

  Widget _buildDestinationCityField(BuildContext context, ShippingState state) {
    final selectedDestinationName = _getSelectedDestinationName(state);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kota Tujuan',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          decoration: InputDecoration(
            hintText: selectedDestinationName ?? 'Cari kota tujuan...',
            prefixIcon: const Icon(Icons.location_on),
            suffixIcon: IconButton(
              icon: Icon(_showDestinationDropdown ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _showDestinationDropdown = !_showDestinationDropdown;
                  _showOriginDropdown = false;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _showDestinationDropdown = true;
              _showOriginDropdown = false;
            });
            context.read<ShippingBloc>().add(SearchCitiesRequested(value));
          },
          onTap: () {
            setState(() {
              _showDestinationDropdown = true;
              _showOriginDropdown = false;
            });
          },
        ),
        if (_showDestinationDropdown) _buildCityDropdown(context, state, false),
      ],
    );
  }

  Widget _buildCityDropdown(BuildContext context, ShippingState state, bool isOrigin) {
    final cities = _getFilteredCities(state);
    
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.surface,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 200.h),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: cities.length,
          itemBuilder: (context, index) {
            final city = cities[index];
            return ListTile(
              title: Text(
                city.cityName,
                style: TextStyle(fontSize: 14.sp),
              ),
              subtitle: Text(
                city.provinceName,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              onTap: () {
                if (isOrigin) {
                  context.read<ShippingBloc>().add(OriginCitySelected(
                    cityId: city.cityId,
                    cityName: '${city.cityName}, ${city.provinceName}',
                  ));
                } else {
                  context.read<ShippingBloc>().add(DestinationCitySelected(
                    cityId: city.cityId,
                    cityName: '${city.cityName}, ${city.provinceName}',
                  ));
                }
                setState(() {
                  _showOriginDropdown = false;
                  _showDestinationDropdown = false;
                });
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildWeightField(BuildContext context, ShippingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Berat (kg)',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _weightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Masukkan berat paket',
            prefixIcon: const Icon(Icons.scale),
            suffixText: 'kg',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          onChanged: (value) {
            final weight = double.tryParse(value) ?? 0.0;
            context.read<ShippingBloc>().add(WeightChanged(weight));
          },
        ),
      ],
    );
  }

  Widget _buildCalculateButton(BuildContext context, ShippingState state) {
    final canCalculate = _canCalculate(state);
    final isCalculating = state is ShippingCalculating;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canCalculate && !isCalculating
            ? () {
                setState(() {
                  _showOriginDropdown = false;
                  _showDestinationDropdown = false;
                });
                context.read<ShippingBloc>().add(const CalculateShippingRequested());
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        icon: isCalculating
            ? SizedBox(
                width: 16.w,
                height: 16.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.calculate),
        label: Text(
          isCalculating ? 'Menghitung...' : 'Hitung Ongkir',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection(BuildContext context, ShippingState state) {
    if (state is! ShippingCalculated) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hasil Perhitungan',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<ShippingBloc>().add(const ResetShippingCalculation());
              },
              child: const Text('Hitung Ulang'),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          '${state.selectedOriginName} → ${state.selectedDestinationName}',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          'Berat: ${state.weight} kg',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        if (state.shippingResults.isEmpty)
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48.w,
                    color: AppColors.warning,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Tidak ada hasil',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Tidak ditemukan layanan pengiriman untuk rute ini',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...state.shippingResults.map((result) => _buildResultCard(context, state, result)),
      ],
    );
  }

  Widget _buildResultCard(BuildContext context, ShippingCalculated state, result) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${result.courier} ${result.service}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      result.description,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.formatRupiah(result.cost),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      result.estimatedTime,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  final shippingText = _formatShippingText(state, result);
                  context.read<ShippingBloc>().add(CopyShippingTextRequested(shippingText));
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                icon: const Icon(Icons.copy),
                label: const Text('Copy ke WhatsApp'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getSelectedOriginName(ShippingState state) {
    if (state is CitiesLoaded) return state.selectedOriginName;
    if (state is ShippingCalculating) return state.selectedOriginName;
    if (state is ShippingCalculated) return state.selectedOriginName;
    if (state is ShippingError) return state.selectedOriginName;
    return null;
  }

  String? _getSelectedDestinationName(ShippingState state) {
    if (state is CitiesLoaded) return state.selectedDestinationName;
    if (state is ShippingCalculating) return state.selectedDestinationName;
    if (state is ShippingCalculated) return state.selectedDestinationName;
    if (state is ShippingError) return state.selectedDestinationName;
    return null;
  }

  List<RajaOngkirCity> _getFilteredCities(ShippingState state) {
    if (state is CitiesLoaded) return state.filteredCities;
    if (state is ShippingError && state.cities != null) return state.cities!;
    return [];
  }

  bool _canCalculate(ShippingState state) {
    if (state is CitiesLoaded) return state.canCalculate;
    return false;
  }

  String _formatShippingText(ShippingCalculated state, result) {
    return '''
🚚 *Detail Pengiriman*

Rute: ${state.selectedOriginName} → ${state.selectedDestinationName}
Kurir: ${result.courier} (${result.service})
Layanan: ${result.description}
Berat: ${state.weight}kg
Ongkos Kirim: ${CurrencyFormatter.formatRupiah(result.cost)}
Estimasi: ${result.estimatedTime}

_Tarif resmi dari kurir terpercaya_
''';
  }
}