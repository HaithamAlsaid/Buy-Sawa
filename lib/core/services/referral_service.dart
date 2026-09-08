import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ReferralService {
  final http.Client client;

  ReferralService({http.Client? client}) : client = client ?? http.Client();

  /// Share a product and get a referral link/token.
  Future<String?> shareProduct(dynamic productId, String token, {dynamic variantId}) async {
    final url = Uri.parse(ApiService.shareProductEndpoint(productId));
    final headers = ApiService.headers(token: token);
    final body = variantId != null ? jsonEncode({'product_variant_id': variantId}) : null;

    try {
      final response = await client.post(url, headers: headers, body: body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // We assume the API returns the token in data['token'] or data['data']['token']
        // or a full url in data['share_url']
        if (data['data'] != null && data['data']['token'] != null) {
          return data['data']['token'];
        } else if (data['token'] != null) {
          return data['token'];
        } else if (data['data'] != null && data['data']['url'] != null) {
           return data['data']['url'];
        }
        return 'success'; // Fallback
      } else {
        print('Error sharing product: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception sharing product: $e');
      return null;
    }
  }

  /// Resolve a referral token (used when the app opens from a deep link).
  Future<bool> resolveReferral(String tokenStr) async {
    final url = Uri.parse(ApiService.resolveLinkEndpoint(tokenStr));
    try {
      final response = await client.get(url, headers: ApiService.headers());
      return response.statusCode == 200;
    } catch (e) {
      print('Exception resolving referral: $e');
      return false;
    }
  }
}
