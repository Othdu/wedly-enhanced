import '../services/api_client.dart';
import '../services/api_constants.dart';

class PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Initiate Paymob payment for the current user's cart
  /// Returns payment data including iframe_url for WebView
  Future<Map<String, dynamic>> initiateCartPayment({
    required String billingFirstName,
    required String billingLastName,
    required String billingEmail,
    required String billingPhone,
    required String billingCity,
    required String billingCountry,
    required String billingStreet,
    required String billingBuilding,
    required String billingFloor,
    required String billingApartment,
    required String billingPostalCode,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.initiatePayment,
      data: {
        'billing_first_name': billingFirstName,
        'billing_last_name': billingLastName,
        'billing_email': billingEmail,
        'billing_phone': billingPhone,
        'billing_city': billingCity,
        'billing_country': billingCountry,
        'billing_street': billingStreet,
        'billing_building': billingBuilding,
        'billing_floor': billingFloor,
        'billing_apartment': billingApartment,
        'billing_postal_code': billingPostalCode,
      },
    );

    final data = response.data['data'];
    return {
      'payment_intent_id': data['payment_intent_id'],
      'paymob_order_id': data['paymob_order_id'],
      'amount_cents': data['amount_cents'],
      'currency': data['currency'],
      'payment_token': data['payment_token'],
      'iframe_url': data['iframe_url'],
    };
  }
}
