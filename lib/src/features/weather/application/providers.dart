import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:try1/src/features/weather/data/weather_repository.dart';
import 'package:try1/src/features/weather/domain/forecast/forecast_data.dart';
import 'package:try1/src/features/weather/domain/weather/weather_data.dart';

final cityProvider = StateProvider<String>((ref) {
  return 'Naga City';
});

final currentWeatherProvider =
    FutureProvider.autoDispose<WeatherData>((ref) async {
  final city = ref.watch(cityProvider);
  final weather =
      await ref.watch(weatherRepositoryProvider).getWeather(city: city);
  return WeatherData.from(weather);
});

final hourlyWeatherProvider =
    FutureProvider.autoDispose<ForecastData>((ref) async {
  final city = ref.watch(cityProvider);
  final forecast =
      await ref.watch(weatherRepositoryProvider).getForecast(city: city);
  return ForecastData.from(forecast);
});
