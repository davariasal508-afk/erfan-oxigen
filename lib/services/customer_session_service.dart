import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer_model.dart';
import 'customer_service.dart';

class CustomerSessionService {
  static const _phoneKey = 'oxygen_customer_phone';
  static CustomerModel? customer;

  static Future<void> createSession(CustomerModel value) async {
    customer = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, value.phone);
  }

  static Future<bool> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString(_phoneKey);
    if (phone == null) return false;
    customer = CustomerService.find(phone);
    if (customer == null) {
      await logout();
      return false;
    }
    return true;
  }

  static Future<void> logout() async {
    customer = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phoneKey);
  }
}
