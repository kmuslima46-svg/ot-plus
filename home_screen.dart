import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ot_entry.dart';
import '../services/ot_database.dart';
import 'ot_entry_screen.dart';
import 'jobs_screen.dart';
import 'ot_history_screen.dart';

const pink = Color(0xFFE81775);
const ink = Color(0xFF30232A);
const softPink = Color(0xFFFCE7F1);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  Future<List<OtEntry>> _entries() => OtDatabase.instance.all();

  @override
  Widget build(BuildContext context) {
    final pages = [
      _home(),
      const OtHistoryScreen(),
      const JobsScreen(),
      const _ProfileScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: tab, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        indicatorColor: softPink,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: pink), label: 'হোম'),
          NavigationDestination(icon: Icon(Icons.access_time), selectedIcon: Icon(Icons.access_time_filled, color: pink), label: 'OT হিসাব'),
          NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work, color: pink), label: 'PLUS Jobs'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: pink), label: 'প্রোফাইল'),
        ],
      ),
    );
  }

  Widget _home() {
    final month = DateFormat('yyyy-MM').format(DateTime.now());
    return FutureBuilder<List<OtEntry>>(
      future: _entries(),
      builder: (context, snapshot) {
        final entries = snapshot.data ?? [];
        final monthly = entries.where((e) => e.date.startsWith(month)).toList();
        final mins = monthly.fold<int>(0, (s, e) => s + e.totalMinutes);
        final amount = monthly.fold<double>(0, (s, e) => s + e.amount);
        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFE81775), Color(0xFFB80D58)]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(children: [
                  const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.access_time_filled, color: Colors.white, size: 30)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('OT PLUS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 21)),
                    const Text('আপনার OT, আপনার হিসাব', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 12),
                    Text('${mins ~/ 60} ঘণ্টা ${mins % 60} মিনিট', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('এই মাসের আনুমানিক আয়: ৳${amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
                  ])),
                ]),
              ),
              const SizedBox(height: 18),
              const Text('দ্রুত কাজ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ink)),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10, crossAxisSpacing: 8, childAspectRatio: .82,
                children: [
                  _action(Icons.add_alarm, 'OT যোগ করুন', () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const OtEntryScreen())); setState(() {}); }),
                  _action(Icons.receipt_long, 'OT ইতিহাস', () => setState(() => tab = 1)),
                  _action(Icons.bar_chart, 'মাসিক রিপোর্ট', () => setState(() => tab = 1)),
                  _action(Icons.search, 'চাকরি খুঁজুন', () => setState(() => tab = 2)),
                  _action(Icons.post_add, 'চাকরি পোস্ট', () => setState(() => tab = 2)),
                  _action(Icons.bookmark_border, 'সেভ করা', () => setState(() => tab = 2)),
                  _action(Icons.calendar_month, 'ক্যালেন্ডার', () => setState(() => tab = 1)),
                  _action(Icons.settings_outlined, 'সেটিংস', () => setState(() => tab = 3)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFFFEFF6), borderRadius: BorderRadius.circular(18)),
                child: Row(children: [
                  const Icon(Icons.factory_outlined, color: pink, size: 40),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('গার্মেন্টসে চাকরি খুঁজুন', style: TextStyle(color: pink, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('আপনার দক্ষতার উপযোগী কাজ'),
                  ])),
                  FilledButton(onPressed: () => setState(() => tab = 2), child: const Text('দেখুন')),
                ]),
              ),
              const SizedBox(height: 18),
              Row(children: [const Expanded(child: Text('সাম্প্রতিক OT হিসাব', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), TextButton(onPressed: () => setState(() => tab = 1), child: const Text('সব দেখুন'))]),
              if (entries.isEmpty)
                const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('এখনও কোনো OT হিসাব যোগ করা হয়নি। “OT যোগ করুন” চাপুন।')))
              else
                ...entries.take(3).map((e) => Card(child: ListTile(
                  leading: const CircleAvatar(backgroundColor: softPink, child: Icon(Icons.access_time, color: pink)),
                  title: Text(DateFormat('dd MMM yyyy').format(DateTime.tryParse(e.date) ?? DateTime.now())),
                  subtitle: Text('${e.hours} ঘণ্টা ${e.minutes} মিনিট'),
                  trailing: Text('৳${e.amount.toStringAsFixed(2)}', style: const TextStyle(color: pink, fontWeight: FontWeight.bold)),
                ))),
              const SizedBox(height: 18),
              const Text('নতুন চাকরি', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Card(child: ListTile(leading: Icon(Icons.work_outline, color: pink), title: Text('PLUS Jobs-এ চাকরি দেখুন'), subtitle: Text('অনলাইন চাকরির তালিকা'), trailing: Icon(Icons.chevron_right))),
            ],
          ),
        );
      },
    );
  }

  Widget _action(IconData icon, String label, VoidCallback onTap) => InkWell(
    borderRadius: BorderRadius.circular(16), onTap: onTap,
    child: Column(children: [
      Container(width: 54, height: 54, decoration: const BoxDecoration(color: softPink, shape: BoxShape.circle), child: Icon(icon, color: pink, size: 27)),
      const SizedBox(height: 6),
      Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11.5, color: ink)),
    ]),
  );
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
    const SizedBox(height: 12),
    const CircleAvatar(radius: 42, backgroundColor: softPink, child: Icon(Icons.person, size: 44, color: pink)),
    const SizedBox(height: 12),
    const Center(child: Text('OT PLUS ব্যবহারকারী', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
    const Center(child: Text('প্রোফাইল সেটআপ ও অ্যাকাউন্ট সুবিধা')),
    const SizedBox(height: 20),
    const Card(child: ListTile(leading: Icon(Icons.person_outline, color: pink), title: Text('ব্যক্তিগত তথ্য'), trailing: Icon(Icons.chevron_right))),
    const Card(child: ListTile(leading: Icon(Icons.backup_outlined, color: pink), title: Text('ডেটা ব্যাকআপ'), subtitle: Text('ক্লাউড সিঙ্ক পরবর্তী ধাপে যোগ করতে হবে'))),
    const Card(child: ListTile(leading: Icon(Icons.privacy_tip_outlined, color: pink), title: Text('গোপনীয়তা ও শর্তাবলি'))),
  ]);
}
