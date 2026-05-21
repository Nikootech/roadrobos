import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://hxoncblbripckfuxijav.supabase.co/rest/v1/profiles?id=eq.5aa61665-05d6-4c3c-9d85-3814c86eb1f2');
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh4b25jYmxicmlwY2tmdXhpamF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNDc1NzMsImV4cCI6MjA5MTYyMzU3M30.VuJ13qv1rEyJyfdAvpCI_qUvPSQPcZqbluLWWo4loBM';
  
  final bodyWithEmail = {
    'email': 'test@test.com'
  };

  final response = await http.patch(
    url,
    headers: {
      'apikey': anonKey,
      'Authorization': 'Bearer $anonKey',
      'Content-Type': 'application/json',
      'Prefer': 'return=representation',
    },
    body: jsonEncode(bodyWithEmail),
  );

  print('Status Email: ${response.statusCode}');
  print('Body Email: ${response.body}');
}
