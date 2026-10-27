import 'package:kigali_weather/weather.dart';

void main() async {
  final weather = await fetchWeather(cities[1]);
  print('Huye: ${weather.temperature}°C, code ${weather.code}');
}