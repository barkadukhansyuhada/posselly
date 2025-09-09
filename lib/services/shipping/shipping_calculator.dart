import '../../core/errors/exceptions.dart';
import 'rajaongkir_api.dart';

class ShippingResult {
  final String courier;
  final String service;
  final String description;
  final double cost;
  final String estimatedTime;

  const ShippingResult({
    required this.courier,
    required this.service,
    required this.description,
    required this.cost,
    required this.estimatedTime,
  });

  factory ShippingResult.fromRajaOngkir(RajaOngkirShippingResult result) {
    return ShippingResult(
      courier: result.courier,
      service: result.service,
      description: result.description,
      cost: result.cost.toDouble(),
      estimatedTime: _parseEtd(result.etd),
    );
  }

  static String _parseEtd(String etd) {
    // Parse ETD like "1-2" to "1-2 hari"
    if (etd.contains('-')) {
      return '$etd hari';
    } else if (etd.isNotEmpty) {
      return '$etd hari';
    }
    return '2-3 hari';
  }
}

class ShippingCalculator {
  final RajaOngkirApi _api = RajaOngkirApi();

  Future<List<RajaOngkirCity>> getCities() async {
    try {
      return await _api.getCities();
    } catch (e) {
      throw ServerException(message: 'Gagal mengambil data kota: $e');
    }
  }

  Future<List<RajaOngkirCity>> searchCities(String query) async {
    try {
      final cities = await getCities();
      return cities
          .where((city) => 
              city.cityName.toLowerCase().contains(query.toLowerCase()) ||
              city.provinceName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Gagal mencari kota: $e');
    }
  }

  Future<double> calculateShippingCost({
    required String originCityId,
    required String destinationCityId,
    required double weightKg,
    required String courier,
    required String service,
  }) async {
    try {
      final weightGrams = (weightKg * 1000).round();
      final results = await _api.getShippingCost(
        originCityId: originCityId,
        destinationCityId: destinationCityId,
        weight: weightGrams,
        courier: courier.toLowerCase(),
      );

      final selectedService = results.firstWhere(
        (result) => result.service.toLowerCase() == service.toLowerCase(),
        orElse: () => results.first,
      );

      return selectedService.cost.toDouble();
    } catch (e) {
      throw ServerException(message: 'Gagal menghitung ongkos kirim: $e');
    }
  }

  Future<List<ShippingResult>> getAllShippingOptions({
    required String originCityId,
    required String destinationCityId,
    required double weightKg,
  }) async {
    try {
      final weightGrams = (weightKg * 1000).round();
      final rajaOngkirResults = await _api.getAllShippingOptions(
        originCityId: originCityId,
        destinationCityId: destinationCityId,
        weight: weightGrams,
      );

      return rajaOngkirResults
          .map((result) => ShippingResult.fromRajaOngkir(result))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Gagal mengambil opsi pengiriman: $e');
    }
  }

  String formatShippingText({
    required String courier,
    required String service,
    required String description,
    required double cost,
    required double weight,
    required String estimatedTime,
    String? originCity,
    String? destinationCity,
  }) {
    return '''
🚚 *Detail Pengiriman*

${originCity != null && destinationCity != null ? 'Rute: $originCity → $destinationCity\n' : ''}Kurir: $courier ($service)
Layanan: $description
Berat: ${weight.toString()}kg
Ongkos Kirim: Rp ${cost.toStringAsFixed(0)}
Estimasi: $estimatedTime

_Tarif resmi dari kurir terpercaya_
''';
  }

  List<String> get availableCouriers {
    return ['JNE', 'POS', 'TIKI'];
  }

  Future<List<String>> getServicesForCourier(
    String courier,
    String originCityId,
    String destinationCityId,
    double weightKg,
  ) async {
    try {
      final weightGrams = (weightKg * 1000).round();
      final results = await _api.getShippingCost(
        originCityId: originCityId,
        destinationCityId: destinationCityId,
        weight: weightGrams,
        courier: courier.toLowerCase(),
      );

      return results.map((result) => result.service).toSet().toList();
    } catch (e) {
      throw ServerException(message: 'Gagal mengambil layanan kurir: $e');
    }
  }
}