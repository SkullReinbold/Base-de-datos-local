import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notas_app/exchange_service.dart';

class FakeAdapter implements HttpClientAdapter {
  final int status;
  final String body;
  FakeAdapter(this.status, this.body);

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    return ResponseBody.fromString(body, status,
        headers: {Headers.contentTypeHeader: ['application/json']});
  }

  @override
  void close({bool force = false}) {}
}

ExchangeService servicio(int status, String body) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.exchangerate-api.com/v4'));
  dio.httpClientAdapter = FakeAdapter(status, body);
  return ExchangeService(dio: dio);
}

void main() {
  test('parsea el JSON correctamente', () async {
    final json = jsonEncode({
      'base': 'MXN',
      'date': '2026-11-23',
      'rates': {'USD': 0.054, 'EUR': 0.05},
    });
    final r = await servicio(200, json).obtenerTasas();
    expect(r.base, 'MXN');
    expect(r.rates['USD'], 0.054);
  });

  test('maneja 404', () async {
    expect(
      servicio(404, '{}').obtenerTasas(),
      throwsA(predicate((e) => e.toString().contains('404'))),
    );
  });

  test('maneja 500', () async {
    expect(
      servicio(500, '{}').obtenerTasas(),
      throwsA(predicate((e) => e.toString().contains('servidor'))),
    );
  });
}