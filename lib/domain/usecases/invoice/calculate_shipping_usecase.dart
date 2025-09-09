import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../services/shipping/shipping_calculator.dart';

class CalculateShippingUsecase {
  final ShippingCalculator calculator;
  
  CalculateShippingUsecase(this.calculator);
  
  Future<Either<Failure, double>> call({
    required String originCityId,
    required String destinationCityId,
    required String courier,
    required String service,
    required double weightKg,
  }) async {
    try {
      final cost = await calculator.calculateShippingCost(
        originCityId: originCityId,
        destinationCityId: destinationCityId,
        courier: courier,
        service: service,
        weightKg: weightKg,
      );
      return Right(cost);
    } catch (e) {
      return Left(ValidationFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<ShippingResult>>> getAllOptions({
    required String originCityId,
    required String destinationCityId,
    required double weightKg,
  }) async {
    try {
      final results = await calculator.getAllShippingOptions(
        originCityId: originCityId,
        destinationCityId: destinationCityId,
        weightKg: weightKg,
      );
      return Right(results);
    } catch (e) {
      return Left(ValidationFailure(message: e.toString()));
    }
  }
}