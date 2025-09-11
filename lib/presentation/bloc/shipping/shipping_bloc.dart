import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/invoice/calculate_shipping_usecase.dart';
import '../../../services/shipping/shipping_calculator.dart';
import 'shipping_event.dart';
import 'shipping_state.dart';

class ShippingBloc extends Bloc<ShippingEvent, ShippingState> {
  final CalculateShippingUsecase _calculateShippingUsecase;
  final ShippingCalculator _shippingCalculator;

  ShippingBloc(
    this._calculateShippingUsecase,
    this._shippingCalculator,
  ) : super(const ShippingInitial()) {
    on<LoadCitiesRequested>(_onLoadCitiesRequested);
    on<SearchCitiesRequested>(_onSearchCitiesRequested);
    on<OriginCitySelected>(_onOriginCitySelected);
    on<DestinationCitySelected>(_onDestinationCitySelected);
    on<WeightChanged>(_onWeightChanged);
    on<CalculateShippingRequested>(_onCalculateShippingRequested);
    on<ResetShippingCalculation>(_onResetShippingCalculation);
    on<CopyShippingTextRequested>(_onCopyShippingTextRequested);
  }

  Future<void> _onLoadCitiesRequested(
    LoadCitiesRequested event,
    Emitter<ShippingState> emit,
  ) async {
    try {
      emit(const ShippingLoading());
      final cities = await _shippingCalculator.getCities();
      emit(CitiesLoaded(
        cities: cities,
        filteredCities: cities,
      ));
    } catch (e) {
      emit(ShippingError(message: 'Gagal memuat data kota: ${e.toString()}'));
    }
  }

  Future<void> _onSearchCitiesRequested(
    SearchCitiesRequested event,
    Emitter<ShippingState> emit,
  ) async {
    if (state is CitiesLoaded) {
      final currentState = state as CitiesLoaded;
      try {
        final filteredCities = event.query.isEmpty
            ? currentState.cities
            : await _shippingCalculator.searchCities(event.query);
        
        emit(currentState.copyWith(filteredCities: filteredCities));
      } catch (e) {
        emit(ShippingError(
          message: 'Gagal mencari kota: ${e.toString()}',
          cities: currentState.cities,
          selectedOriginId: currentState.selectedOriginId,
          selectedOriginName: currentState.selectedOriginName,
          selectedDestinationId: currentState.selectedDestinationId,
          selectedDestinationName: currentState.selectedDestinationName,
          weight: currentState.weight,
        ));
      }
    }
  }

  void _onOriginCitySelected(
    OriginCitySelected event,
    Emitter<ShippingState> emit,
  ) {
    if (state is CitiesLoaded) {
      final currentState = state as CitiesLoaded;
      emit(currentState.copyWith(
        selectedOriginId: event.cityId,
        selectedOriginName: event.cityName,
        filteredCities: currentState.cities, // Reset filter
      ));
    }
  }

  void _onDestinationCitySelected(
    DestinationCitySelected event,
    Emitter<ShippingState> emit,
  ) {
    if (state is CitiesLoaded) {
      final currentState = state as CitiesLoaded;
      emit(currentState.copyWith(
        selectedDestinationId: event.cityId,
        selectedDestinationName: event.cityName,
        filteredCities: currentState.cities, // Reset filter
      ));
    }
  }

  void _onWeightChanged(
    WeightChanged event,
    Emitter<ShippingState> emit,
  ) {
    if (state is CitiesLoaded) {
      final currentState = state as CitiesLoaded;
      emit(currentState.copyWith(weight: event.weight));
    }
  }

  Future<void> _onCalculateShippingRequested(
    CalculateShippingRequested event,
    Emitter<ShippingState> emit,
  ) async {
    if (state is CitiesLoaded) {
      final currentState = state as CitiesLoaded;
      
      if (!currentState.canCalculate) {
        emit(ShippingError(
          message: 'Lengkapi data kota asal, kota tujuan, dan berat',
          cities: currentState.cities,
          selectedOriginId: currentState.selectedOriginId,
          selectedOriginName: currentState.selectedOriginName,
          selectedDestinationId: currentState.selectedDestinationId,
          selectedDestinationName: currentState.selectedDestinationName,
          weight: currentState.weight,
        ));
        return;
      }

      try {
        emit(ShippingCalculating(
          selectedOriginId: currentState.selectedOriginId,
          selectedOriginName: currentState.selectedOriginName,
          selectedDestinationId: currentState.selectedDestinationId,
          selectedDestinationName: currentState.selectedDestinationName,
          weight: currentState.weight,
        ));

        final result = await _calculateShippingUsecase.getAllOptions(
          originCityId: currentState.selectedOriginId!,
          destinationCityId: currentState.selectedDestinationId!,
          weightKg: currentState.weight,
        );

        result.fold(
          (failure) => emit(ShippingError(
            message: failure.message,
            cities: currentState.cities,
            selectedOriginId: currentState.selectedOriginId,
            selectedOriginName: currentState.selectedOriginName,
            selectedDestinationId: currentState.selectedDestinationId,
            selectedDestinationName: currentState.selectedDestinationName,
            weight: currentState.weight,
          )),
          (shippingResults) => emit(ShippingCalculated(
            cities: currentState.cities,
            selectedOriginId: currentState.selectedOriginId!,
            selectedOriginName: currentState.selectedOriginName!,
            selectedDestinationId: currentState.selectedDestinationId!,
            selectedDestinationName: currentState.selectedDestinationName!,
            weight: currentState.weight,
            shippingResults: shippingResults,
          )),
        );
      } catch (e) {
        emit(ShippingError(
          message: 'Gagal menghitung ongkos kirim: ${e.toString()}',
          cities: currentState.cities,
          selectedOriginId: currentState.selectedOriginId,
          selectedOriginName: currentState.selectedOriginName,
          selectedDestinationId: currentState.selectedDestinationId,
          selectedDestinationName: currentState.selectedDestinationName,
          weight: currentState.weight,
        ));
      }
    }
  }

  void _onResetShippingCalculation(
    ResetShippingCalculation event,
    Emitter<ShippingState> emit,
  ) {
    if (state is ShippingCalculated) {
      final currentState = state as ShippingCalculated;
      emit(CitiesLoaded(
        cities: currentState.cities,
        filteredCities: currentState.cities,
        selectedOriginId: currentState.selectedOriginId,
        selectedOriginName: currentState.selectedOriginName,
        selectedDestinationId: currentState.selectedDestinationId,
        selectedDestinationName: currentState.selectedDestinationName,
        weight: currentState.weight,
      ));
    }
  }

  Future<void> _onCopyShippingTextRequested(
    CopyShippingTextRequested event,
    Emitter<ShippingState> emit,
  ) async {
    try {
      await Clipboard.setData(ClipboardData(text: event.shippingText));
      emit(const ShippingTextCopied('Teks berhasil disalin ke clipboard'));
      
      // Return to previous state after showing success message
      await Future.delayed(const Duration(milliseconds: 1500));
      if (state is ShippingTextCopied) {
        // Emit the previous state back
        if (state is ShippingCalculated) {
          // Keep the calculated state
        } else {
          add(const LoadCitiesRequested());
        }
      }
    } catch (e) {
      emit(ShippingError(message: 'Gagal menyalin teks: ${e.toString()}'));
    }
  }
}