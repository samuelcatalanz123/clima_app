# Clima — App de Flutter con internet 🌤️

App móvil hecha con **Flutter** (Dart) que muestra el **clima real** de cualquier
ciudad, trayendo los datos de internet desde la API gratuita **Open-Meteo**
(sin clave). Demuestra cómo **conectar una app a internet**.

> Hecha por Samuel 💜

## Qué hace

- 🔎 Escribes una ciudad y la app trae su clima actual.
- 🌡️ Muestra **temperatura**, un **emoji** del clima, su **descripción** y el **viento**.
- ⏳ Muestra una ruedita mientras carga y un mensaje claro si hay error.

## Cómo funciona (lo nuevo)

- Usa el paquete **`http`** para hacer peticiones a internet.
- Encadena **2 APIs** de Open-Meteo:
  1. **Geocodificación**: nombre de la ciudad → coordenadas.
  2. **Pronóstico**: coordenadas → clima actual.
- Lee la respuesta en **JSON** (`jsonDecode`) y la muestra.

```dart
final resp = await http.get(Uri.parse('https://...'));
final datos = jsonDecode(resp.body);
```

## Cómo ejecutar

```bash
flutter pub get
flutter run            # emulador o dispositivo
# o en el navegador:
flutter run -d chrome
```

Código en `lib/main.dart` (la pantalla) y `lib/clima.dart` (la conexión a internet).

## Stack

Flutter · Dart · http · API Open-Meteo (gratis, sin clave).
