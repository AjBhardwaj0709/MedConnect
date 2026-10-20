
class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      "https://supportively-unforbidding-roseanna.ngrok-free.dev";

  // Authentication
  static const String patientSignup = "/api/auth/patient/signup";
  static const String doctorSignup = "/api/auth/doctor/signup";
  static const String login = "/api/auth/login";
  static const String currentUser = "/api/auth/me";

  // Doctor profile
  static const String doctorProfile = "/api/doctors/profile";

  // Doctor availability
static const String doctorAvailability = '/api/doctors/availability';

  static String doctorAvailabilityById(String id) => '$doctorAvailability/$id';
}
