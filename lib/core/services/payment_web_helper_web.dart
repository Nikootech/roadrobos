import 'dart:js_interop';

@JS('payWithRazorpayWeb')
external void _payWithRazorpayWeb(
  JSAny options,
  JSFunction onSuccess,
  JSFunction onFailure,
);

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
  final optionsMap = {
    'key': apiKey,
    'amount': amountInPaise,
    if (orderId != null && orderId.isNotEmpty) 'order_id': orderId,
    'name': 'RoadRobos Services',
    'description': description,
    'prefill': {
      'contact': contact,
      'email': email,
    },
    'theme': {'color': '#0EA5E9'}
  };

  final optionsJS = optionsMap.jsify();

  if (optionsJS != null) {
    _payWithRazorpayWeb(
      optionsJS,
      ((JSString paymentId, JSString? orderId, JSString? signature) {
        onSuccess(
          paymentId.toDart,
          orderId?.toDart,
          signature?.toDart,
        );
      }).toJS,
      ((JSString error) {
        onFailure(error.toDart);
      }).toJS,
    );
  }
}
