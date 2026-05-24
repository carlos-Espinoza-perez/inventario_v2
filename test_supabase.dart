import 'package:supabase_flutter/supabase_flutter.dart';
void main() {
  final client = SupabaseClient('https://mock', 'mock');
  client.auth.setSession('mock_refresh_token');
}
