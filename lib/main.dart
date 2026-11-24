import 'package:flutter/material.dart';
import 'exchange_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tipo de cambio',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const TasasPage(),
    );
  }
}

class TasasPage extends StatefulWidget {
  const TasasPage({super.key});
  @override
  State<TasasPage> createState() => _TasasPageState();
}

class _TasasPageState extends State<TasasPage> {
  final _service = ExchangeService();
  late Future<ExchangeRate> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.obtenerTasas();
  }

  void _reintentar() => setState(() => _future = _service.obtenerTasas());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tipo de cambio (base MXN)')),
      body: FutureBuilder<ExchangeRate>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 8),
                Text('${snap.error}', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                    onPressed: _reintentar, child: const Text('Reintentar')),
              ]),
            );
          }
          final data = snap.data!;
          final monedas = data.rates.entries.toList();
          return Column(children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Actualizado: ${data.date}'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: monedas.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(monedas[i].key),
                  trailing: Text(monedas[i].value.toStringAsFixed(4)),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}