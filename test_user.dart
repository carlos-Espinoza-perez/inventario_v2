import 'package:supabase/supabase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  final client = SupabaseClient(supabaseUrl, supabaseAnonKey);
  
  final res = await client.from('usuario').select().eq('id', '046a62db-f9b9-470b-a714-8e09d16e8d89');
  print('Usuario: $res');
}
