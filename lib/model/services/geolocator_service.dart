import 'package:geolocator/geolocator.dart';

class GeolocatorService {
  Future<void> checkLocationService() async {
    bool servicestatus = await Geolocator.isLocationServiceEnabled();
    if (!servicestatus) {
      throw Exception("Serviço de localização desabilitado. Habilite-o para lançar despesas.");
    }
  }

  Future<void> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    String errorMessage = "Permissão de localização é necessária para o correto funcionamento do aplicativo e a autenticidade das despesas. Certifique-se de habilitar as permissões de localização.";

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception(errorMessage);
      }
    }
  }

  Future<Map<String, String>> getLatLong() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    String lat = position.latitude.toString();
    String long = position.longitude.toString();

    return {
      "latitude": lat,
      "longitude": long,
    };
  }
}
