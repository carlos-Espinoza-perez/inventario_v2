void main() {
  String url = 'io.supabase.inventario://login-callback/#/%23access_token=eyJhbGciOiJIUz';
  String fixedUrl = url.replaceAll('%23', '#').replaceAll('/#/#', '#');
  print('Original: $url');
  print('Fixed:    $fixedUrl');
}
