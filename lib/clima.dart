import 'dart:convert';
import 'package:http/http.dart' as http;

// El clima de UN día (para el pronóstico).
class Dia {
  final String fecha;
  final double max;
  final double min;
  final int codigo;
  Dia({required this.fecha, required this.max, required this.min, required this.codigo});
}

// Clima guarda los datos que traemos de internet.
class Clima {
  final String ciudad;
  final double temperatura;
  final double viento;
  final int codigo; // código del clima (estándar WMO)
  final List<Dia> dias; // pronóstico de los próximos días

  Clima({
    required this.ciudad,
    required this.temperatura,
    required this.viento,
    required this.codigo,
    required this.dias,
  });
}

// obtenerClima trae el clima de una ciudad desde internet (API Open-Meteo, gratis).
Future<Clima> obtenerClima(String ciudad) async {
  // 1) Geocodificación: convertir el nombre de la ciudad en coordenadas.
  final geoUrl = Uri.parse(
    'https://geocoding-api.open-meteo.com/v1/search'
    '?name=${Uri.encodeComponent(ciudad)}&count=1&language=es',
  );
  final geoResp = await http.get(geoUrl);
  final geoData = jsonDecode(geoResp.body);
  final resultados = geoData['results'];
  if (resultados == null || resultados.isEmpty) {
    throw Exception('No encontré esa ciudad. Revisa cómo la escribiste.');
  }
  final lugar = resultados[0];
  final lat = lugar['latitude'];
  final lon = lugar['longitude'];
  final nombre = lugar['name'];
  final pais = lugar['country'] ?? '';

  // 2) Pronóstico: clima actual + los próximos días.
  final climaUrl = Uri.parse(
    'https://api.open-meteo.com/v1/forecast'
    '?latitude=$lat&longitude=$lon&current_weather=true'
    '&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=auto',
  );
  final climaResp = await http.get(climaUrl);
  final climaData = jsonDecode(climaResp.body);
  final actual = climaData['current_weather'];

  // Leemos las LISTAS del pronóstico por día.
  final daily = climaData['daily'];
  final fechas = daily['time'] as List;
  final maxs = daily['temperature_2m_max'] as List;
  final mins = daily['temperature_2m_min'] as List;
  final codigos = daily['weathercode'] as List;

  final dias = <Dia>[];
  for (int i = 0; i < fechas.length && i < 6; i++) {
    dias.add(Dia(
      fecha: fechas[i],
      max: (maxs[i] as num).toDouble(),
      min: (mins[i] as num).toDouble(),
      codigo: codigos[i],
    ));
  }

  return Clima(
    ciudad: pais.isEmpty ? nombre : '$nombre, $pais',
    temperatura: (actual['temperature'] as num).toDouble(),
    viento: (actual['windspeed'] as num).toDouble(),
    codigo: actual['weathercode'],
    dias: dias,
  );
}

// Un emoji según el código del clima.
String emojiClima(int c) {
  if (c == 0) return '☀️';
  if (c <= 3) return '⛅';
  if (c <= 48) return '🌫️';
  if (c <= 67) return '🌧️';
  if (c <= 77) return '🌨️';
  if (c <= 82) return '🌦️';
  return '⛈️';
}

// Una descripción en texto según el código del clima.
String descripcionClima(int c) {
  if (c == 0) return 'Despejado';
  if (c <= 3) return 'Parcialmente nublado';
  if (c <= 48) return 'Neblina';
  if (c <= 67) return 'Lluvia';
  if (c <= 77) return 'Nieve';
  if (c <= 82) return 'Chubascos';
  return 'Tormenta';
}

// Devuelve el nombre corto del día (Lun, Mar...) a partir de una fecha "2026-05-31".
String nombreDia(String fechaIso) {
  final d = DateTime.parse(fechaIso);
  const nombres = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  return nombres[d.weekday - 1];
}
