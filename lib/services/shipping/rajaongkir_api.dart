import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';
import '../../core/errors/exceptions.dart';

class RajaOngkirCity {
  final String cityId;
  final String cityName;
  final String provinceName;

  const RajaOngkirCity({
    required this.cityId,
    required this.cityName,
    required this.provinceName,
  });

  factory RajaOngkirCity.fromJson(Map<String, dynamic> json) {
    return RajaOngkirCity(
      cityId: json['city_id'].toString(),
      cityName: json['city_name'] as String,
      provinceName: json['province'] as String,
    );
  }

  factory RajaOngkirCity.fromNewApiJson(Map<String, dynamic> json) {
    return RajaOngkirCity(
      cityId: json['id'].toString(),
      cityName: json['city_name'] as String? ?? json['label'] as String,
      provinceName: json['province_name'] as String,
    );
  }
}

class RajaOngkirCost {
  final String service;
  final String description;
  final List<RajaOngkirCostDetail> cost;

  const RajaOngkirCost({
    required this.service,
    required this.description,
    required this.cost,
  });

  factory RajaOngkirCost.fromJson(Map<String, dynamic> json) {
    return RajaOngkirCost(
      service: json['service'] as String,
      description: json['description'] as String,
      cost: (json['cost'] as List)
          .map((item) => RajaOngkirCostDetail.fromJson(item))
          .toList(),
    );
  }
}

class RajaOngkirCostDetail {
  final int value;
  final String etd;
  final String note;

  const RajaOngkirCostDetail({
    required this.value,
    required this.etd,
    required this.note,
  });

  factory RajaOngkirCostDetail.fromJson(Map<String, dynamic> json) {
    return RajaOngkirCostDetail(
      value: json['value'] as int,
      etd: json['etd'] as String,
      note: json['note'] as String? ?? '',
    );
  }
}

class RajaOngkirShippingResult {
  final String courier;
  final String service;
  final String description;
  final int cost;
  final String etd;

  const RajaOngkirShippingResult({
    required this.courier,
    required this.service,
    required this.description,
    required this.cost,
    required this.etd,
  });
}

class RajaOngkirApi {
  late final Dio _dio;

  RajaOngkirApi() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.rajaOngkirBaseUrl,
      headers: {
        'x-api-key': AppConfig.rajaOngkirApiKey,
        'content-type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<List<RajaOngkirCity>> getCities() async {
    try {
      // Check if using mock data due to enterprise account requirement
      if (AppConfig.useMockShippingData) {
        // Return comprehensive list of Indonesian cities for demo
        return _getMockCities();
      }
      
      // Attempt real API call (requires enterprise account)
      final response = await _dio.get('/destination/search?keyword=');
      
      if (response.statusCode == 200 && response.data['meta']['status'] == 'success') {
        final cities = (response.data['data'] as List)
            .map((city) => RajaOngkirCity.fromNewApiJson(city))
            .toList();
        return cities;
      } else {
        throw ServerException(
          message: response.data['meta']['message'] ?? 'Gagal mengambil data kota',
        );
      }
    } on DioException {
      // Fallback to mock data on network error
      return _getMockCities();
    } catch (_) {
      // Fallback to mock data on any error
      return _getMockCities();
    }
  }

  List<RajaOngkirCity> _getMockCities() {
    return [
      // Major Indonesian Cities for Demo
      const RajaOngkirCity(cityId: '152', cityName: 'Jakarta Selatan', provinceName: 'DKI Jakarta'),
      const RajaOngkirCity(cityId: '153', cityName: 'Jakarta Timur', provinceName: 'DKI Jakarta'),
      const RajaOngkirCity(cityId: '154', cityName: 'Jakarta Utara', provinceName: 'DKI Jakarta'),
      const RajaOngkirCity(cityId: '155', cityName: 'Jakarta Barat', provinceName: 'DKI Jakarta'),
      const RajaOngkirCity(cityId: '156', cityName: 'Jakarta Pusat', provinceName: 'DKI Jakarta'),
      const RajaOngkirCity(cityId: '444', cityName: 'Surabaya', provinceName: 'Jawa Timur'),
      const RajaOngkirCity(cityId: '23', cityName: 'Bandung', provinceName: 'Jawa Barat'),
      const RajaOngkirCity(cityId: '182', cityName: 'Malang', provinceName: 'Jawa Timur'),
      const RajaOngkirCity(cityId: '399', cityName: 'Semarang', provinceName: 'Jawa Tengah'),
      const RajaOngkirCity(cityId: '39', cityName: 'Bekasi', provinceName: 'Jawa Barat'),
      const RajaOngkirCity(cityId: '419', cityName: 'Tangerang', provinceName: 'Banten'),
      const RajaOngkirCity(cityId: '17', cityName: 'Balikpapan', provinceName: 'Kalimantan Timur'),
      const RajaOngkirCity(cityId: '274', cityName: 'Palembang', provinceName: 'Sumatera Selatan'),
      const RajaOngkirCity(cityId: '317', cityName: 'Pekanbaru', provinceName: 'Riau'),
      const RajaOngkirCity(cityId: '252', cityName: 'Medan', provinceName: 'Sumatera Utara'),
      const RajaOngkirCity(cityId: '80', cityName: 'Denpasar', provinceName: 'Bali'),
      const RajaOngkirCity(cityId: '242', cityName: 'Makassar', provinceName: 'Sulawesi Selatan'),
      const RajaOngkirCity(cityId: '338', cityName: 'Pontianak', provinceName: 'Kalimantan Barat'),
      const RajaOngkirCity(cityId: '167', cityName: 'Yogyakarta', provinceName: 'DI Yogyakarta'),
      const RajaOngkirCity(cityId: '501', cityName: 'Batam', provinceName: 'Kepulauan Riau'),
    ];
  }

  Future<List<RajaOngkirShippingResult>> getShippingCost({
    required String originCityId,
    required String destinationCityId,
    required int weight, // in grams
    required String courier, // jne, pos, tiki
  }) async {
    try {
      // Check if using mock data due to enterprise account requirement
      if (AppConfig.useMockShippingData) {
        return _getMockShippingCost(originCityId, destinationCityId, weight, courier);
      }
      
      // Attempt real API call (requires enterprise account)
      // TODO: Implement actual API call when enterprise API key is available
      
      // For now, fallback to mock data
      return _getMockShippingCost(originCityId, destinationCityId, weight, courier);
    } on DioException {
      // Fallback to mock data on network error
      return _getMockShippingCost(originCityId, destinationCityId, weight, courier);
    } catch (_) {
      // Fallback to mock data on any error  
      return _getMockShippingCost(originCityId, destinationCityId, weight, courier);
    }
  }

  List<RajaOngkirShippingResult> _getMockShippingCost(
    String originCityId, 
    String destinationCityId, 
    int weight, 
    String courier
  ) {
    // Calculate realistic shipping costs based on distance and weight
    final baseCost = _calculateBaseCost(originCityId, destinationCityId);
    final weightMultiplier = (weight / 1000).ceil(); // Per kg
    
    final mockResults = <RajaOngkirShippingResult>[];
    
    if (courier.toLowerCase() == 'jne') {
      mockResults.addAll([
        RajaOngkirShippingResult(
          courier: 'JNE',
          service: 'REG',
          description: 'Layanan Reguler',
          cost: (baseCost * weightMultiplier * 1.0).toInt(),
          etd: _getEstimatedDelivery(originCityId, destinationCityId, false),
        ),
        RajaOngkirShippingResult(
          courier: 'JNE',
          service: 'YES',
          description: 'Yakin Esok Sampai',
          cost: (baseCost * weightMultiplier * 1.8).toInt(),
          etd: _getEstimatedDelivery(originCityId, destinationCityId, true),
        ),
      ]);
    } else if (courier.toLowerCase() == 'pos') {
      mockResults.addAll([
        RajaOngkirShippingResult(
          courier: 'POS',
          service: 'Paket Kilat Khusus',
          description: 'Pos Kilat Khusus',
          cost: (baseCost * weightMultiplier * 0.85).toInt(),
          etd: _getEstimatedDelivery(originCityId, destinationCityId, false),
        ),
      ]);
    } else if (courier.toLowerCase() == 'tiki') {
      mockResults.addAll([
        RajaOngkirShippingResult(
          courier: 'TIKI',
          service: 'REG',
          description: 'Regular Service',
          cost: (baseCost * weightMultiplier * 0.9).toInt(),
          etd: _getEstimatedDelivery(originCityId, destinationCityId, false),
        ),
      ]);
    }

    return mockResults;
  }

  int _calculateBaseCost(String originCityId, String destinationCityId) {
    // Realistic base costs based on typical Indonesian shipping routes
    final jakartatCities = ['152', '153', '154', '155', '156']; // Jakarta
    final javaMainCities = ['444', '23', '182', '399', '39', '419', '167']; // Surabaya, Bandung, etc.
    
    bool originInJakarta = jakartatCities.contains(originCityId);
    bool destInJakarta = jakartatCities.contains(destinationCityId);
    bool originInJava = javaMainCities.contains(originCityId) || originInJakarta;
    bool destInJava = javaMainCities.contains(destinationCityId) || destInJakarta;
    
    // Same city
    if (originCityId == destinationCityId) return 8000;
    
    // Within Jakarta
    if (originInJakarta && destInJakarta) return 10000;
    
    // Within Java island
    if (originInJava && destInJava) return 12000;
    
    // Java to outer islands or vice versa
    if (originInJava != destInJava) return 20000;
    
    // Between outer islands
    return 25000;
  }
  
  String _getEstimatedDelivery(String originCityId, String destinationCityId, bool isExpress) {
    // Same city
    if (originCityId == destinationCityId) {
      return isExpress ? '1' : '1-2';
    }
    
    final jakartatCities = ['152', '153', '154', '155', '156'];
    final javaMainCities = ['444', '23', '182', '399', '39', '419', '167'];
    
    bool originInJava = javaMainCities.contains(originCityId) || jakartatCities.contains(originCityId);
    bool destInJava = javaMainCities.contains(destinationCityId) || jakartatCities.contains(destinationCityId);
    
    // Within Java
    if (originInJava && destInJava) {
      return isExpress ? '1-2' : '2-3';
    }
    
    // To outer islands
    return isExpress ? '2-3' : '3-5';
  }

  Future<List<RajaOngkirShippingResult>> getAllShippingOptions({
    required String originCityId,
    required String destinationCityId,
    required int weight,
  }) async {
    try {
      final allResults = <RajaOngkirShippingResult>[];

      for (final courier in AppConfig.supportedCouriers) {
        try {
          final results = await getShippingCost(
            originCityId: originCityId,
            destinationCityId: destinationCityId,
            weight: weight,
            courier: courier,
          );
          allResults.addAll(results);
        } catch (e) {
          // Continue with next courier if one fails
          print('Error getting shipping cost for $courier: $e');
        }
      }

      // Sort by cost
      allResults.sort((a, b) => a.cost.compareTo(b.cost));
      return allResults;
    } catch (e) {
      throw ServerException(message: 'Gagal mengambil opsi pengiriman: $e');
    }
  }
}