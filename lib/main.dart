import 'package:flutter/material.dart';
import 'clima.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clima',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PantallaClima(),
    );
  }
}

class PantallaClima extends StatefulWidget {
  const PantallaClima({super.key});

  @override
  State<PantallaClima> createState() => _PantallaClimaState();
}

class _PantallaClimaState extends State<PantallaClima> {
  final _ciudad = TextEditingController(text: 'Guatemala');
  Clima? _clima;
  bool _cargando = false;
  String _error = '';

  Future<void> _buscar() async {
    final ciudad = _ciudad.text.trim();
    if (ciudad.isEmpty) return;

    setState(() {
      _cargando = true;
      _error = '';
      _clima = null;
    });

    try {
      final clima = await obtenerClima(ciudad); // ¡aquí hablamos con internet!
      setState(() => _clima = clima);
    } catch (e) {
      setState(() => _error = 'No pude traer el clima. ¿Escribiste bien la ciudad?');
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text('🌤️ Clima',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 20),
                // Buscador
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ciudad,
                        onSubmitted: (_) => _buscar(),
                        decoration: InputDecoration(
                          hintText: 'Escribe una ciudad...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _buscar,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2193b0),
                      ),
                      child: const Icon(Icons.search),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Resultado
                Expanded(child: _contenido()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _contenido() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Text(_error, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
      );
    }
    if (_clima == null) {
      return const Center(
        child: Text('Busca una ciudad para ver su clima.',
            style: TextStyle(color: Colors.white70, fontSize: 16)),
      );
    }
    // Tarjeta con el clima
    final c = _clima!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(c.ciudad,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text(emojiClima(c.codigo), style: const TextStyle(fontSize: 90)),
          Text('${c.temperatura.toStringAsFixed(1)}°C',
              style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold)),
          Text(descripcionClima(c.codigo),
              style: const TextStyle(color: Colors.white, fontSize: 20)),
          const SizedBox(height: 20),
          Text('💨 Viento: ${c.viento.toStringAsFixed(0)} km/h',
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }
}
