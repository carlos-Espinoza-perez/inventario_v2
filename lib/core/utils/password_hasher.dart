import 'package:bcrypt/bcrypt.dart';

class PasswordHasher {
  static String hashPassword(String plainPassword) {
    final String hashed = BCrypt.hashpw(plainPassword, BCrypt.gensalt());
    return hashed;
  }

  static bool checkPassword(String plainPassword, String hashedPassword) {
    try {
      return BCrypt.checkpw(plainPassword, hashedPassword);
    } catch (e) {
      return false;
    }
  }
}
