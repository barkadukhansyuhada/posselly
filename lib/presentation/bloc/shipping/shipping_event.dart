import 'package:equatable/equatable.dart';

abstract class ShippingEvent extends Equatable {
  const ShippingEvent();

  @override
  List<Object?> get props => [];
}

class LoadCitiesRequested extends ShippingEvent {
  const LoadCitiesRequested();
}

class SearchCitiesRequested extends ShippingEvent {
  final String query;

  const SearchCitiesRequested(this.query);

  @override
  List<Object?> get props => [query];
}

class OriginCitySelected extends ShippingEvent {
  final String cityId;
  final String cityName;

  const OriginCitySelected({
    required this.cityId,
    required this.cityName,
  });

  @override
  List<Object?> get props => [cityId, cityName];
}

class DestinationCitySelected extends ShippingEvent {
  final String cityId;
  final String cityName;

  const DestinationCitySelected({
    required this.cityId,
    required this.cityName,
  });

  @override
  List<Object?> get props => [cityId, cityName];
}

class WeightChanged extends ShippingEvent {
  final double weight;

  const WeightChanged(this.weight);

  @override
  List<Object?> get props => [weight];
}

class CalculateShippingRequested extends ShippingEvent {
  const CalculateShippingRequested();
}

class ResetShippingCalculation extends ShippingEvent {
  const ResetShippingCalculation();
}

class CopyShippingTextRequested extends ShippingEvent {
  final String shippingText;

  const CopyShippingTextRequested(this.shippingText);

  @override
  List<Object?> get props => [shippingText];
}