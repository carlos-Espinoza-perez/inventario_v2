void main() {
  String url = 'io.supabase.inventario://login-callback/#/%23access_token=eyJhbGciOiJIUz';
  String fixedUrl = url.replaceAll('%23', '#').replaceAll('/#/#', '#');
  // ignore: avoid_print
  print('Original: $url');
  // ignore: avoid_print
  print('Fixed:    $fixedUrl');
}
