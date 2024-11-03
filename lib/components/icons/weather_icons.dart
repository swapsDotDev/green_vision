import 'package:flutter/material.dart';

class WeatherIcons {
  // Day icons
  static const IconData day_sunny = Icons.wb_sunny;
  static const IconData day_cloudy = Icons.wb_cloudy;
  static const IconData day_cloudy_gusts = Icons.cloudy_snowing;
  static const IconData day_cloudy_windy = Icons.air;
  static const IconData day_fog = Icons.blur_on;
  static const IconData day_hail = Icons.grain;
  static const IconData day_haze = Icons.blur_linear;
  static const IconData day_lightning = Icons.flash_on;
  static const IconData day_rain = Icons.grain;
  static const IconData day_rain_mix = Icons.water;
  static const IconData day_rain_wind = Icons.waves;
  static const IconData day_showers = Icons.shower;
  static const IconData day_sleet = Icons.ac_unit;
  static const IconData day_snow = Icons.ac_unit;
  static const IconData day_sprinkle = Icons.grain;
  static const IconData day_storm_showers = Icons.thunderstorm;
  static const IconData day_sunny_overcast = Icons.wb_cloudy;
  static const IconData day_thunderstorm = Icons.flash_on;
  static const IconData day_windy = Icons.air;

  // Night icons
  static const IconData night_clear = Icons.nightlight_round;
  static const IconData night_cloudy = Icons.nights_stay;
  static const IconData night_cloudy_gusts = Icons.cloudy_snowing;
  static const IconData night_cloudy_windy = Icons.air;
  static const IconData night_fog = Icons.blur_on;
  static const IconData night_hail = Icons.grain;
  static const IconData night_lightning = Icons.flash_on;
  static const IconData night_rain = Icons.grain;
  static const IconData night_rain_mix = Icons.water;
  static const IconData night_rain_wind = Icons.waves;
  static const IconData night_showers = Icons.shower;
  static const IconData night_sleet = Icons.ac_unit;
  static const IconData night_snow = Icons.ac_unit;
  static const IconData night_sprinkle = Icons.grain;
  static const IconData night_storm_showers = Icons.thunderstorm;
  static const IconData night_thunderstorm = Icons.flash_on;

  // Neutral icons
  static const IconData cloud = Icons.cloud;
  static const IconData cloudy = Icons.cloud;
  static const IconData cloudy_gusts = Icons.cloudy_snowing;
  static const IconData cloudy_windy = Icons.air;
  static const IconData fog = Icons.blur_on;
  static const IconData hail = Icons.grain;
  static const IconData lightning = Icons.flash_on;
  static const IconData rain = Icons.grain;
  static const IconData rain_mix = Icons.water;
  static const IconData rain_wind = Icons.waves;
  static const IconData showers = Icons.shower;
  static const IconData sleet = Icons.ac_unit;
  static const IconData snow = Icons.ac_unit;
  static const IconData sprinkle = Icons.grain;
  static const IconData storm_showers = Icons.thunderstorm;
  static const IconData thunderstorm = Icons.flash_on;
  static const IconData windy = Icons.air;

  // Misc icons
  static const IconData humidity = Icons.water_drop;
  static const IconData pressure = Icons.speed;
  static const IconData sunrise = Icons.wb_twilight;
  static const IconData sunset = Icons.nights_stay;
  static const IconData temperature = Icons.thermostat;
  static const IconData windDirection = Icons.navigation;
  static const IconData visibility = Icons.visibility;
  static const IconData uvIndex = Icons.wb_sunny_outlined;
  static const IconData moonPhase = Icons.brightness_2;
  static const IconData precipitation = Icons.opacity;
  static const IconData cloudCover = Icons.cloud_queue;

  // Helper method to get weather icon based on condition and time of day
  static IconData getWeatherIcon(String condition, {bool isDay = true}) {
    String lowercaseCondition = condition.toLowerCase();
    if (isDay) {
      switch (lowercaseCondition) {
        case 'clear':
        case 'sunny':
          return day_sunny;
        case 'partly cloudy':
          return day_cloudy;
        case 'cloudy':
        case 'overcast':
          return cloudy;
        case 'rain':
        case 'drizzle':
          return day_rain;
        case 'thunderstorm':
          return day_thunderstorm;
        case 'snow':
          return day_snow;
        case 'fog':
          return day_fog;
        case 'windy':
          return day_windy;
        default:
          return day_sunny;
      }
    } else {
      switch (lowercaseCondition) {
        case 'clear':
          return night_clear;
        case 'partly cloudy':
          return night_cloudy;
        case 'cloudy':
        case 'overcast':
          return cloudy;
        case 'rain':
        case 'drizzle':
          return night_rain;
        case 'thunderstorm':
          return night_thunderstorm;
        case 'snow':
          return night_snow;
        case 'fog':
          return night_fog;
        case 'windy':
          return windy;
        default:
          return night_clear;
      }
    }
  }

  // Helper method to get colored weather icon
  static Icon getColoredWeatherIcon(String condition, {bool isDay = true, Color? color, double? size}) {
    return Icon(
      getWeatherIcon(condition, isDay: isDay),
      color: color ?? Colors.black,
      size: size ?? 24.0,
    );
  }
}