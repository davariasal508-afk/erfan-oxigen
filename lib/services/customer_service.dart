import 'dart:math';

import '../models/customer_model.dart';
import 'storage_service.dart';

class CustomerService {
  static const _key = 'oxygen_customers_v3';
  static const _legacyKey = 'oxygen_customers_v2';
  static final List<CustomerModel> customers = [];
  static final Map<String, ({String code, DateTime expiresAt})> _otps = {};

  static Future<void> initialize() async {
    var raw = await StorageService.loadGenericList(_key);
    if (raw.isEmpty) {
      raw = await StorageService.loadGenericList(_legacyKey);
      if (raw.isNotEmpty) {
        await StorageService.saveGenericList(_key, raw);
      }
    }
    customers
      ..clear()
      ..addAll(raw.map(CustomerModel.fromJson));
  }

  static Future<void> addCustomer(
    String phone, {
    String name = 'مشتری',
    DateTime? birthday,
  }) async {
    final cleanPhone = _normalizePhone(phone);
    if (customers.any((c) => c.phone == cleanPhone)) return;
    customers.add(
      CustomerModel(
        id: 'customer_${DateTime.now().microsecondsSinceEpoch}',
        name: name.trim().isEmpty ? 'مشتری' : name.trim(),
        phone: cleanPhone,
        birthday: birthday,
      ),
    );
    await _save();
  }

  static Future<void> updateCustomer(
    CustomerModel customer, {
    String? name,
    DateTime? birthday,
    bool? active,
  }) async {
    if (name != null && name.trim().isNotEmpty) {
      customer.name = name.trim();
    }
    if (birthday != null) customer.birthday = birthday;
    if (active != null) customer.active = active;
    await _save();
  }

  static Future<void> updateName(CustomerModel customer, String name) async {
    await updateCustomer(customer, name: name);
  }

  static Future<void> setActive(CustomerModel customer, bool active) async {
    await updateCustomer(customer, active: active);
  }

  static Future<void> remove(CustomerModel customer) async {
    customers.removeWhere((c) => c.id == customer.id);
    await _save();
  }

  static CustomerModel? find(String phone) {
    final cleanPhone = _normalizePhone(phone);
    return customers.where((c) => c.phone == cleanPhone && c.active).firstOrNull;
  }

  static bool isRegistered(String phone) => find(phone) != null;

  static Future<String?> requestOtp(String phone) async {
    final customer = find(phone);
    if (customer == null) return null;
    final code = (100000 + Random().nextInt(900000)).toString();
    _otps[_normalizePhone(phone)] = (
      code: code,
      expiresAt: DateTime.now().add(const Duration(minutes: 2)),
    );
    return code;
  }

  static bool verifyOtp(String phone, String code) {
    final key = _normalizePhone(phone);
    final otp = _otps[key];
    if (otp == null || DateTime.now().isAfter(otp.expiresAt) || otp.code != code.trim()) {
      return false;
    }
    _otps.remove(key);
    return true;
  }

  static Future<void> markPhoneVerified(CustomerModel customer) async {
    customer.phoneVerified = true;
    await _save();
  }

  static Future<void> claimBirthdayGift(CustomerModel customer) async {
    customer.birthdayGiftClaimedYear = DateTime.now().year;
    await _save();
  }

  static String _normalizePhone(String phone) {
    var value = phone.trim().replaceAll(' ', '').replaceAll('-', '');
    if (value.startsWith('0098')) value = '+98${value.substring(4)}';
    if (value.startsWith('98') && !value.startsWith('+')) value = '+$value';
    if (value.startsWith('0')) value = '+98${value.substring(1)}';
    return value;
  }

  static Future<void> _save() => StorageService.saveGenericList(
        _key,
        customers.map((e) => e.toJson()).toList(),
      );
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
