

class RoleChecker {
  static const String _adminEmail = "a.qadir1201@gmail.com";

  static bool isAdminEmail(String email) {
    return email.trim().toLowerCase() == _adminEmail.toLowerCase();
  }
}