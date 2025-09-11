import 'package:equatable/equatable.dart';

import '../../../services/shipping/rajaongkir_api.dart';
import '../../../services/shipping/shipping_calculator.dart';

abstract class ShippingState extends Equatable {
  const ShippingState();

  @override
  List<Object?> get props => [];
}

class ShippingInitial extends ShippingState {
  const ShippingInitial();
}

class ShippingLoading extends ShippingState {
  const ShippingLoading();
}

class CitiesLoaded extends ShippingState {
  final List<RajaOngkirCity> cities;
  final List<RajaOngkirCity> filteredCities;
  final String? selectedOriginId;
  final String? selectedOriginName;
  final String? selectedDestinationId;
  final String? selectedDestinationName;
  final double weight;

  const CitiesLoaded({
    required this.cities,
    required this.filteredCities,
    this.selectedOriginId,
    this.selectedOriginName,
    this.selectedDestinationId,
    this.selectedDestinationName,
    this.weight = 1.0,
  });

  CitiesLoaded copyWith({
    List<RajaOngkirCity>? cities,
    List<RajaOngkirCity>? filteredCities,
    String? selectedOriginId,
    String? selectedOriginName,
    String? selectedDestinationId,
    String? selectedDestinationName,
    double? weight,
  }) {
    return CitiesLoaded(
      cities: cities ?? this.cities,
      filteredCities: filteredCities ?? this.filteredCities,
      selectedOriginId: selectedOriginId ?? this.selectedOriginId,
      selectedOriginName: selectedOriginName ?? this.selectedOriginName,
      selectedDestinationId: selectedDestinationId ?? this.selectedDestinationId,
      selectedDestinationName: selectedDestinationName ?? this.selectedDestinationName,
      weight: weight ?? this.weight,
    );
  }

  bool get canCalculate => 
      selectedOriginId != null && 
      selectedDestinationId != null && 
      weight > 0;

  @override
  List<Object?> get props => [
        cities,
        filteredCities,
        selectedOriginId,
        selectedOriginName,
        selectedDestinationId,
        selectedDestinationName,
        weight,
      ];
}

class ShippingCalculating extends ShippingState {
  final String? selectedOriginId;
  final String? selectedOriginName;
  final String? selectedDestinationId;
  final String? selectedDestinationName;
  final double weight;

  const ShippingCalculating({
    this.selectedOriginId,
    this.selectedOriginName,
    this.selectedDestinationId,
    this.selectedDestinationName,
    this.weight = 1.0,
  });

  @override
  List<Object?> get props => [
        selectedOriginId,
        selectedOriginName,
        selectedDestinationId,
        selectedDestinationName,
        weight,
      ];
}

class ShippingCalculated extends ShippingState {
  final List<RajaOngkirCity> cities;
  final String selectedOriginId;
  final String selectedOriginName;
  final String selectedDestinationId;
  final String selectedDestinationName;
  final double weight;
  final List<ShippingResult> shippingResults;

  const ShippingCalculated({
    required this.cities,
    required this.selectedOriginId,
    required this.selectedOriginName,
    required this.selectedDestinationId,
    required this.selectedDestinationName,
    required this.weight,
    required this.shippingResults,
  });

  @override
  List<Object?> get props => [
        cities,
        selectedOriginId,
        selectedOriginName,
        selectedDestinationId,
        selectedDestinationName,
        weight,
        shippingResults,
      ];
}

class ShippingError extends ShippingState {
  final String message;
  final List<RajaOngkirCity>? cities;
  final String? selectedOriginId;
  final String? selectedOriginName;
  final String? selectedDestinationId;
  final String? selectedDestinationName;
  final double weight;

  const ShippingError({
    required this.message,
    this.cities,
    this.selectedOriginId,
    this.selectedOriginName,
    this.selectedDestinationId,
    this.selectedDestinationName,
    this.weight = 1.0,
  });

  @override
  List<Object?> get props => [
        message,
        cities,
        selectedOriginId,
        selectedOriginName,
        selectedDestinationId,
        selectedDestinationName,
        weight,
      ];
}

class ShippingTextCopied extends ShippingState {
  final String message;

  const ShippingTextCopied(this.message);

  @override
  List<Object?> get props => [message];
}