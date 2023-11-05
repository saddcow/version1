  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:flutter/material.dart';
  import 'package:geolocator/geolocator.dart';
  import 'package:google_maps_flutter/google_maps_flutter.dart';
  import 'package:flutter_geocoder/geocoder.dart' as geoCo;

  class Mapstry extends StatefulWidget {
    const Mapstry({super.key});
    @override
    _MapstryState createState() => _MapstryState();
  }

  class _MapstryState extends State<Mapstry> {
    GoogleMapController? googleMapController;
    Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
    late Position position;
    String? addressLocation;
    String? country;
    String? postalCode;

    void getMarkers(double lat, double long) {
      MarkerId markerId = MarkerId(lat.toString() + long.toString());
      Marker _marker = Marker(
          markerId: markerId,
          position: LatLng(lat, long),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          infoWindow: InfoWindow(snippet: 'Address'));
      setState(() {
        markers[markerId] = _marker;
      });
    }

    void getCurrentLocation() async{
      Position currentPosition = await GeolocatorPlatform.instance.getCurrentPosition();
      setState(() {
        position = currentPosition;
      });
    }

    @override
    void initState() {
      super.initState();
      getCurrentLocation();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Container(
          child: Column(
            children: [
              SizedBox(
                height: 450.0,
                child: GoogleMap(
                  onTap: (tapped) async{
                    final coordinated = geoCo.Coordinates(tapped.latitude, tapped.longitude);
                    var address = await geoCo.Geocoder.local.findAddressesFromCoordinates(
                      coordinated
                    );
                    var firstAddress = address.first;
                    getMarkers(tapped.latitude, tapped.longitude);
                    await FirebaseFirestore.instance.collection('location').add({
                      'latitude': tapped.latitude,
                      'longitude': tapped.longitude,
                      'Address': firstAddress.addressLine
                    });
                    setState(() {
                        country = firstAddress.countryName!; 
                        postalCode = firstAddress.postalCode!;
                        addressLocation = firstAddress.addressLine!;
                    });
                  },
                  onMapCreated: (GoogleMapController controller){
                      setState(() {
                        googleMapController = controller;
                      });
                  },
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(13.6217753, 123.1948238), zoom: 15.0),
                  markers: Set<Marker>.of(markers.values)),
              ),
              Text('Address : $addressLocation'),
              Text('PostalCode : $postalCode'),
              Text('Country : $country'),
            ],
          ),
        ),
      );
    }
    @override
    void dispose() {
      super.dispose();
    }
  }
