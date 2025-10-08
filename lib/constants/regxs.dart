class Regxs {
  static String emailRegx =
      r'^[a-z0-9]+([._%+-]?[a-z0-9]+)*@[a-z0-9-]+(\.[a-z]{2,})+$';
  static String passwordRegx =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';

  // Validate email format
  static bool validateEmail(String email) {
    return RegExp(emailRegx).hasMatch(email);
  }

  // Validate password format
  static bool validatePassword(String password) {
    return RegExp(passwordRegx).hasMatch(password);
  }

}
