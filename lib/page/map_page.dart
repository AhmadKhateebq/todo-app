import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_geo_hash/geohash.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  String long = '';
  String lat = '';
  String hash = '';

  @override
  Widget build(context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Permission.locationWhenInUse.request().then((permissionStatus) => {
                  if (permissionStatus.isGranted)
                    {
                      Geolocator.getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.high,
                      ).then((position) => {
                            log(position.longitude.toString(),
                                name: "longitude"),
                            log(position.latitude.toString(), name: "latitude"),
                            setState(() {
                              MyGeoHash myGeoHash = MyGeoHash();
                              hash = myGeoHash.geoHashForLocation(
                                  GeoPoint(
                                      position.latitude, position.longitude),precision: 7);
                              lat = position.latitude.toString();
                              long = position.longitude.toString();
                            })
                          })
                    }
                });
          },
          child: const Icon(Icons.arrow_back_ios_outlined),
        ),
        appBar: AppBar(),
        body: ListTile(title: Text("long : $long,lat: $lat"), subtitle: Text("hash : $hash")));
  }
}
