import 'package:flutter/material.dart';

import '../../models/customer_model.dart';
import '../../services/customer_service.dart';
import '../../theme/app_theme.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String query = '';

  Future<void> _add() async {
    final phone = TextEditingController();
    final name = TextEditingController(text: 'مشتری');
    DateTime? birthday;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('ثبت مشتری'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'نام مشتری')),
              const SizedBox(height: 10),
              TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'شماره موبایل')),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cake_rounded, color: AppTheme.gold),
                title: const Text('تاریخ تولد'),
                subtitle: Text(birthday == null ? 'ثبت نشده' : _formatDate(birthday!)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1940),
                    lastDate: DateTime.now(),
                    initialDate: birthday ?? DateTime(2000, 1, 1),
                    builder: (context, child) => Theme(data: Theme.of(context), child: child!),
                  );
                  if (picked != null) setDialogState(() => birthday = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('انصراف')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('ثبت مشتری')),
          ],
        ),
      ),
    );
    if (ok == true && phone.text.trim().isNotEmpty) {
      await CustomerService.addCustomer(phone.text.trim(), name: name.text.trim(), birthday: birthday);
      if (mounted) setState(() {});
    }
    phone.dispose();
    name.dispose();
  }

  Future<void> _edit(CustomerModel customer) async {
    final name = TextEditingController(text: customer.name);
    DateTime? birthday = customer.birthday;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('ویرایش مشتری'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'نام')),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cake_rounded, color: AppTheme.gold),
                title: const Text('تاریخ تولد'),
                subtitle: Text(birthday == null ? 'ثبت نشده' : _formatDate(birthday!)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1940),
                    lastDate: DateTime.now(),
                    initialDate: birthday ?? DateTime(2000, 1, 1),
                  );
                  if (picked != null) setDialogState(() => birthday = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('انصراف')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('ذخیره')),
          ],
        ),
      ),
    );
    if (ok == true) {
      await CustomerService.updateCustomer(customer, name: name.text, birthday: birthday);
      if (mounted) setState(() {});
    }
    name.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = query.trim().toLowerCase();
    final list = CustomerService.customers.where((c) => q.isEmpty || c.phone.contains(q) || c.name.toLowerCase().contains(q)).toList();
    return OxygenPage(
      title: 'مشتری‌ها',
      floatingActionButton: FloatingActionButton.extended(onPressed: _add, backgroundColor: AppTheme.gold, foregroundColor: Colors.black, icon: const Icon(Icons.person_add_alt_1_rounded), label: const Text('ثبت مشتری')),
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(18, 14, 18, 8), child: TextField(onChanged: (v) => setState(() => query = v), decoration: const InputDecoration(hintText: 'جستجوی شماره یا نام', prefixIcon: Icon(Icons.search)))),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('مشتری ثبت نشده است', style: TextStyle(color: AppTheme.muted)))
                : ListView.separated(
                    padding: const EdgeInsets.all(18),
                    itemCount: list.length,
                    separatorBuilder: (context, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final c = list[index];
                      return Container(
                        padding: const EdgeInsets.all(15),
                        decoration: AppTheme.glass(radius: 18),
                        child: Row(
                          children: [
                            Container(width: 50, height: 50, decoration: AppTheme.goldGlow(radius: 15), child: const Icon(Icons.person_rounded, color: Colors.black)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                                  const SizedBox(height: 3),
                                  Text(c.phone, style: const TextStyle(color: AppTheme.muted)),
                                  if (c.birthday != null) Text('تولد: ${_formatDate(c.birthday!)}', style: const TextStyle(color: AppTheme.gold, fontSize: 11)),
                                  if (c.phoneVerified) const Text('شماره تأیید شده', style: TextStyle(color: AppTheme.success, fontSize: 11)),
                                ],
                              ),
                            ),
                            Switch(value: c.active, onChanged: (v) async { await CustomerService.setActive(c, v); if (mounted) setState(() {}); }),
                            IconButton(onPressed: () => _edit(c), icon: const Icon(Icons.edit_rounded)),
                            IconButton(onPressed: () async { await CustomerService.remove(c); if (mounted) setState(() {}); }, icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) => '${value.year}/${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}';
}
