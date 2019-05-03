/* File to get location of user
* used dependencies - location => to get location coordinates of user,
*   - geoLocation => To get Address from the location coordinates
 */
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';

Future<Address> getUserLocation() async {
  Map<String, double> _currentLocation = new Map();
  Map<String, double> _myLocation;
  String _error;
  Location _location = new Location();
  try {
    _myLocation = await _location.getLocation();
  } on PlatformException catch (exception) {
    if (exception.code == 'PERMISSION_DENIED') {
      _error = 'please grant permission';
      print(_error);
    }
    if (exception.code == 'PERMISSION_DENIED_NEVER_ASK') {
      _error = 'permission denied- please enable it from app settings';
      print(_error);
    }
    _myLocation = null;
  }
  _currentLocation = _myLocation;
  final Coordinates _coordinates = new Coordinates(_currentLocation['latitude'], _currentLocation['longitude']);
  List<Address> _addresses = await Geocoder.local.findAddressesFromCoordinates(_coordinates);
  Address _first = _addresses.first;
  return _first;
}
