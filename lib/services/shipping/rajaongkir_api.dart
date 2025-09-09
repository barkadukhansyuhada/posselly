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
        'key': AppConfig.rajaOngkirApiKey,
        'content-type': 'application/x-www-form-urlencoded',
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
      final response = await _dio.get('/city');
      
      if (response.statusCode == 200 && response.data['rajaongkir']['status']['code'] == 200) {
        final cities = (response.data['rajaongkir']['results'] as List)
            .map((city) => RajaOngkirCity.fromJson(city))
            .toList();
        return cities;
      } else {
        throw ServerException(
          message: response.data['rajaongkir']['status']['description'] ?? 'Gagal mengambil data kota',
        );
      }
    } on DioException catch (e) {
      throw NetworkException('Koneksi bermasalah: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error: $e');
    }
  }

  Future<List<RajaOngkirShippingResult>> getShippingCost({
    required String originCityId,
    required String destinationCityId,
    required int weight, // in grams
    required String courier, // jne, pos, tiki
  }) async {
    try {
      final response = await _dio.post(
        '/cost',
        data: {
          'origin': originCityId,
          'destination': destinationCityId,
          'weight': weight,
          'courier': courier,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      
      if (response.statusCode == 200 && response.data['rajaongkir']['status']['code'] == 200) {
        final results = <RajaOngkirShippingResult>[];
        final courierData = response.data['rajaongkir']['results'][0];
        final costs = (courierData['costs'] as List)
            .map((item) => RajaOngkirCost.fromJson(item))
            .toList();

        for (final cost in costs) {
          for (final detail in cost.cost) {
            results.add(RajaOngkirShippingResult(
              courier: courier.toUpperCase(),
              service: cost.service,
              description: cost.description,
              cost: detail.value,
              etd: detail.etd,
            ));
          }
        }

        return results;
      } else {
        throw ServerException(
          message: response.data['rajaongkir']['status']['description'] ?? 'Gagal menghitung ongkos kirim',
        );
      }
    } on DioException catch (e) {
      throw NetworkException('Koneksi bermasalah: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error: $e');
    }
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