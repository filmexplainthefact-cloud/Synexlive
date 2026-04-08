class AppValidators {
  static String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }
  static String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
  static String? validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required';
    if (v.trim().length < 2) return 'Name too short';
    if (v.trim().length > 30) return 'Name too long';
    return null;
  }
  static String? validateTitle(String? v) {
    if (v == null || v.trim().isEmpty) return 'Title is required';
    if (v.trim().length < 3) return 'Title too short';
    if (v.trim().length > 60) return 'Title too long';
    return null;
  }
  static String? validateConfirmPassword(String? v, String password) {
    if (v == null || v.isEmpty) return 'Confirm your password';
    if (v != password) return 'Passwords do not match';
    return null;
  }
}
