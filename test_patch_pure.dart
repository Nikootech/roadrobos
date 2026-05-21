import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://hxoncblbripckfuxijav.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh4b25jYmxicmlwY2tmdXhpamF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNDc1NzMsImV4cCI6MjA5MTYyMzU3M30.VuJ13qv1rEyJyfdAvpCI_qUvPSQPcZqbluLWWo4loBM',
  );

  try {
    await supabase.from('profiles').update({
      'name': 'Test User',
      'phone': '1234567890',
      'email': 'test@example.com',
      'role': 'customer',
      'profile_pic': null,
    }).eq('id', '5aa61665-05d6-4c3c-9d85-3814c86eb1f2');
    print('Update successful');
  } on PostgrestException catch (e) {
    print('PostgrestException: ${e.message}');
    print('Details: ${e.details}');
    print('Hint: ${e.hint}');
  } catch (e) {
    print('Exception: $e');
  }
}
