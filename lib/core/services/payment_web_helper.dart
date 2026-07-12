void payWithRazorpayWeb({
  required String apiKey,
  required int amountInPaise,
  required String? orderId,
  required String description,
  required String contact,
  required String email,
  required Function(String paymentId, String? orderId, String? signature) onSuccess,
  required Function(String error) onFailure,
}) {
  throw UnsupportedError('Razorpay Web is only supported on Web platform.');
}
