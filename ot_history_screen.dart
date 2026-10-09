import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ot_entry.dart';
import '../services/ot_database.dart';
import 'home_screen.dart';
import 'ot_entry_screen.dart';

class OtHistoryScreen extends StatefulWidget {
  const OtHistoryScreen({super.key});
  @override
  State<OtHistoryScreen> createState() => _OtHistoryScreenState();
}

class _OtHistoryScreenState extends State<OtHistoryScreen> {
  late Future<List<OtEntry>> future;
  @override
  void initState() { super.initState(); future = OtDatabase.instance.all(); }
  void reload() => setState(() => future = OtDatabase.instance.all());

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('OT হিসাবের ইতিহাস'), actions: [IconButton(onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const OtEntryScreen())); reload(); }, icon: const Icon(Icons.add_circle_outline, color: pink))]),
    body: FutureBuilder<List<OtEntry>>(future: future, builder: (context, s) {
      final entries = s.data ?? [];
      final mins = entries.fold<int>(0, (a, e) => a + e.totalMinutes);
      final total = entries.fold<double>(0, (a, e) => a + e.amount);
      return ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('মোট OT সময়'), Text('${mins ~/ 60} ঘণ্টা ${mins % 60} মিনিট', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))])),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('আনুমানিক আয়'), Text('৳${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: pink))])),
        ]))),
        const SizedBox(height: 12),
        if (entries.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('কোনো হিসাব নেই। + চাপ দিয়ে OT যোগ করুন।'))),
        ...entries.map((e) => Card(child: ListTile(
          leading: const CircleAvatar(backgroundColor: softPink, child: Icon(Icons.access_time, color: pink)),
          title: Text(DateFormat('dd MMM yyyy').format(DateTime.tryParse(e.date) ?? DateTime.now())),
          subtitle: Text('${e.hours} ঘণ্টা ${e.minutes} মিনিট • রেট ৳${e.hourlyRate.toStringAsFixed(2)}${e.note.isEmpty ? '' : '\n${e.note}'}'),
          isThreeLine: e.note.isNotEmpty,
          trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('৳${e.amount.toStringAsFixed(2)}', style: const TextStyle(color: pink, fontWeight: FontWeight.bold)),
            IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.delete_outline, size: 19), onPressed: () async {
              final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('হিসাব মুছবেন?'), content: const Text('এই OT এন্ট্রি স্থায়ীভাবে মুছে যাবে।'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('না')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('মুছুন'))]));
              if (ok == true && e.id != null) { await OtDatabase.instance.delete(e.id!); reload(); }
            }),
          ]),
        ))),
      ]);
    }),
  );
}
