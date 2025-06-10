// emergency_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String accountSid = dotenv.env['TWILIO_SID']!;
final String token = dotenv.env['TWILIO_AUTH_TOKEN']!;
final String twilioPhoneNumber = dotenv.env['TWILIO_NUMBER']!;

class EmergencyService {
  static String accountSid = accountSid;
  static String authToken = token;
  static String twilioPhoneNumber = twilioPhoneNumber;

  // Replace with real emergency contact numbers
  static const List<String> emergencyContacts = [
    '+918208183855',
    '+918329656426',
    '+918446144948'
  ];

  /// Sends emergency SMS to all configured contacts
  static Future<bool> sendEmergencyAlert({
    String? customMessage,
    Position? location,
  }) async {
    try {
      String locationText = '';

      // Get current location if not provided
      location ??= await _getCurrentLocationSafely();

      if (location != null) {
        locationText = '\nLocation: https://maps.google.com/?q=${location.latitude},${location.longitude}';
      } 
      else {
        locationText = '\nLocation: https://maps.google.com/?q=19.8307038,75.2868469';
      }

      // Construct emergency message (simplified for deliverability)
final String message = customMessage ??
  'Jeevan Bhandhu Alert\n'
  'This is a safety alert from Shantanu Kulkarni.\n'
  'They may be in danger and need urgent help.\n'
  'Check on them or contact emergency services.\n'
  '$locationText\n'
  'Time: ${DateTime.now()}\n'
  'If false alarm, they"ll follow up.';


      // Send SMS to all contacts
      bool allSent = true;
      for (String phoneNumber in emergencyContacts) {
        bool sent = await _sendSMS(phoneNumber, message);
        if (!sent) {
          allSent = false;
          print('Failed to send SMS to $phoneNumber');
        }
      }

      return allSent;
    } catch (e) {
      print('Error sending emergency alert: $e');
      return false;
    }
  }

  /// Send SMS using Twilio API
  static Future<bool> _sendSMS(String toPhoneNumber, String message) async {
    try {
      final String url = 'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': twilioPhoneNumber,
          'To': toPhoneNumber,
          'Body': message,
        },
      );

      if (response.statusCode == 201) {
        print('SMS sent successfully to $toPhoneNumber');
        return true;
      } else {
        print('Failed to send SMS. Status: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending SMS to $toPhoneNumber: $e');
      return false;
    }
  }

  /// Get current location safely with error handling
  static Future<Position?> _getCurrentLocationSafely() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services are disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Could not get location: $e');
      return null;
    }
  }

  /// (Optional) Placeholder for email alerts
  static Future<bool> sendEmergencyEmail({
    String? customMessage,
    Position? location,
  }) async {
    print('Email alert functionality - implement if needed');
    return true;
  }

  /// (Optional) Emergency call placeholder
  static Future<void> makeEmergencyCall(String phoneNumber) async {
    try {
      // Use url_launcher to make call in real app
      // await launchUrl(Uri.parse('tel:$phoneNumber'));
      print('Emergency call to $phoneNumber - implement with url_launcher');
    } catch (e) {
      print('Error making emergency call: $e');
    }
  }
}
