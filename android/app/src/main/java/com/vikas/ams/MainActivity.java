package com.vikas.ams;

import android.os.Bundle;

import java.util.Locale;

import android.location.Geocoder;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import android.location.Address;

import java.util.List;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "flutter.native/locationHelper";
    Geocoder geocoder;
    List<Address> addresses;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        geocoder = new Geocoder(this, Locale.getDefault());
        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        if (call.method.equals("getAddressFromCordinates")) {
                            try {
                                addresses = geocoder.getFromLocation(19.124157, 72.8447872, 1);
                                String address = addresses.get(0).getAddressLine(0) + ", " + addresses.get(0).getLocality(); // If any additional address line present than only, check with max available address lines by getMaxAddressLineIndex()
                                result.success(address);
                            } catch (Exception e) {
                                result.success("cannot find address");
                            }
                        }
                    }
                });
    }
}
