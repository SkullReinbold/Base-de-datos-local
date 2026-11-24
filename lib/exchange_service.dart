import 'package:dio/dio.dart';

// Modelo: representa el JSON de la API
class ExchangeRate {
  final String base;
  final String date;
  final Map<String, double> rates;

  ExchangeRate({required this.base, required this.date, required this.rates});

  factory ExchangeRate.fromJson(Map<String, dynamic> json) => ExchangeRate(
        base: json['base'] as String,
        date: json['date'] as String,
        rates: (json['rates'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
      );
}

// Error con mensaje amigable para mostrar en la vista
class ApiException implements Exception {
  final String mensaje;
  ApiException(this.mensaje);
  @override
  String toString() => mensaje;
}

class ExchangeService {
  final Dio _dio;

  ExchangeService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://api.exchangerate-api.com/v4',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  // GET https://api.exchangerate-api.com/v4/latest/MXN
  Future<ExchangeRate> obtenerTasas({String base = 'MXN'}) async {
    try {
      final res = await _dio.get('/latest/$base');
      return ExchangeRate.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw ApiException('Tiempo de espera agotado. Revisa tu conexión.');
        case DioExceptionType.connectionError:
          throw ApiException('Sin conexión a internet.');
        case DioExceptionType.badResponse:
          final code = e.response?.statusCode;
          if (code == 404) throw ApiException('Recurso no encontrado (404).');
          if (code != null && code >= 500) {
            throw ApiException('Error del servidor ($code). Intenta más tarde.');
          }
          throw ApiException('Error HTTP $code.');
        default:
          throw ApiException('Error inesperado: ${e.message}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error al procesar la respuesta.');
    }
  }
}