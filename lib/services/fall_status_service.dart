class FallStatusService {
  static String fallStatus = "No fall detected";

  static void setFallDetected() {
    fallStatus = "Fall detected!";
  }

  static void reset() {
    fallStatus = "No fall detected";
  }
}