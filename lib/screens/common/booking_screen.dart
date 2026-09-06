import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../services/customer_session_service.dart';
import '../../theme/app_theme.dart';

class _Service {
  final String name;
  final String duration;
  final String price;
  final IconData icon;
  const _Service(this.name, this.duration, this.price, this.icon);
}

const _services = [
  _Service('کوتاهی کلاسیک و فید', '۳۰ دقیقه', '۲۵۰,۰۰۰ تومان', Icons.content_cut_rounded),
  _Service('اصلاح و طراحی ریش', '۲۰ دقیقه', '۱۵۰,۰۰۰ تومان', Icons.face_retouching_natural_rounded),
  _Service('رنگ و مش مردانه', '۹۰ دقیقه', '۵۵۰,۰۰۰ تومان', Icons.palette_rounded),
  _Service('پکیج VIP کامل', '۱۲۰ دقیقه', '۹۵۰,۰۰۰ تومان', Icons.workspace_premium_rounded),
];

const _times = ['10:00', '11:30', '13:00', '15:00', '16:30', '18:00', '19:30'];

/// «نوبت من» — رزرو واقعی نوبت مشتری (سرویس، تاریخ، ساعت) + مشاهده نوبت‌های قبلی.
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);
  int _serviceIndex = 0;
  DateTime _date = DateTime.now();
  String? _time;

  String get _phone => CustomerSessionService.customer?.phone ?? '';
  String get _name => CustomerSessionService.customer?.name ?? 'مشتری';

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OxygenPage(
      title: 'نوبت من',
      child: Column(
        children: [
          TabBar(
            controller: _tab,
            labelColor: AppTheme.gold,
            unselectedLabelColor: Colors.white54,
            indicatorColor: AppTheme.gold,
            tabs: const [Tab(text: 'رزرو نوبت جدید'), Tab(text: 'نوبت‌های من')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [_buildForm(), _buildHistory()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      children: [
        const SectionTitle(title: 'انتخاب سرویس'),
        const SizedBox(height: 10),
        ...List.generate(_services.length, (i) {
          final s = _services[i];
          final selected = _serviceIndex == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => setState(() => _serviceIndex = i),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: selected ? AppTheme.goldGlow(radius: 18) : AppTheme.glass(radius: 18),
                child: Row(
                  children: [
                    Icon(s.icon, color: selected ? Colors.black : AppTheme.gold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.name, style: TextStyle(fontWeight: FontWeight.w800, color: selected ? Colors.black : Colors.white)),
                          Text('${s.duration} • ${s.price}', style: TextStyle(fontSize: 11, color: selected ? Colors.black87 : AppTheme.muted)),
                        ],
                      ),
                    ),
                    if (selected) const Icon(Icons.check_circle_rounded, color: Colors.black),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 18),
        const SectionTitle(title: 'انتخاب تاریخ'),
        const SizedBox(height: 10),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final day = DateTime.now().add(Duration(days: i));
              final selected = day.year == _date.year && day.month == _date.month && day.day == _date.day;
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _date = day),
                child: Container(
                  width: 58,
                  decoration: selected ? AppTheme.goldGlow(radius: 16) : AppTheme.glass(radius: 16),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_weekday(day.weekday), style: TextStyle(fontSize: 10, color: selected ? Colors.black87 : AppTheme.muted)),
                      const SizedBox(height: 4),
                      Text('${day.day}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: selected ? Colors.black : Colors.white)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        const SectionTitle(title: 'انتخاب ساعت'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _times.map((t) {
            final selected = _time == t;
            return ChoiceChip(
              label: Text(t),
              selected: selected,
              onSelected: (_) => setState(() => _time = t),
              selectedColor: AppTheme.gold,
              labelStyle: TextStyle(color: selected ? Colors.black : Colors.white, fontWeight: FontWeight.w700),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 54,
          child: FilledButton.icon(
            onPressed: _time == null ? null : _confirm,
            icon: const Icon(Icons.event_available_rounded),
            label: const Text('ثبت درخواست نوبت'),
          ),
        ),
      ],
    );
  }

  Widget _buildHistory() {
    final bookings = BookingService.forCustomer(_phone);
    if (bookings.isEmpty) {
      return const Center(child: Text('هنوز نوبتی ثبت نکرده‌اید.', style: TextStyle(color: AppTheme.muted)));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final b = bookings[index];
        final color = switch (b.status) {
          BookingStatus.confirmed => AppTheme.success,
          BookingStatus.cancelled => AppTheme.danger,
          BookingStatus.completed => AppTheme.info,
          _ => AppTheme.gold,
        };
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: AppTheme.glass(radius: 18),
          child: Row(
            children: [
              Container(width: 4, height: 44, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(99))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.service, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text('${b.date.year}/${b.date.month.toString().padLeft(2, '0')}/${b.date.day.toString().padLeft(2, '0')} • ساعت ${b.time}', style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
                  ],
                ),
              ),
              Text(BookingService.statusLabel(b.status), style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w800)),
            ],
          ),
        );
      },
    );
  }

  String _weekday(int w) => const ['دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه', 'شنبه', 'یکشنبه'][w - 1].substring(0, 2);

  Future<void> _confirm() async {
    await BookingService.submit(
      customerPhone: _phone,
      customerName: _name,
      service: _services[_serviceIndex].name,
      date: _date,
      time: _time!,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('درخواست نوبت ثبت شد. منتظر تأیید مدیر باشید.')));
    setState(() {
      _time = null;
      _tab.animateTo(1);
    });
  }
}
