import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ot_entry.dart';
import '../services/ot_database.dart';
import 'home_screen.dart';

class OtEntryScreen extends StatefulWidget {
  const OtEntryScreen({super.key});
  @override
  State<OtEntryScreen> createState() => _OtEntryScreenState();
}

class _OtEntryScreenState extends State<OtEntryScreen> {
  DateTime date = DateTime.now();
  final hours = TextEditingController(text: '2');
  final minutes = TextEditingController(text: '30');
  final rate = TextEditingController(text: '125');
  final note = TextEditingController();
  bool saving = false;

  double get amount {
    final h = int.tryParse(hours.text) ?? 0;
    final m = int.tryParse(minutes.text) ?? 0;
    final r = double.tryParse(rate.text) ?? 0;
    return (h * 60 + m) / 60 * r;
  }

  @override
  void dispose() {
    hours.dispose(); minutes.dispose(); rate.dispose(); note.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final h = int.tryParse(hours.text);
    final m = int.tryParse(minutes.text);
    final r = double.tryParse(rate.text);
    if (h == null || h < 0 || m == null || m < 0 || m > 59 || r == null || r <= 0 || h + m == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সঠিক ঘণ্টা, মিনিট ও রেট দিন। মিনিট ০–৫৯ হতে হবে।')));
      return;
    }
    setState(() => saving = true);
    await OtDatabase.instance.insert(OtEntry(
      date: DateFormat('yyyy-MM-dd').format(date),
      hours: h, minutes: m, hourlyRate: r, note: note.text.trim(),
    ));
    if (mounted) { setState(() => saving = false); Navigator.pop(context); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('নতুন OT এন্ট্রি')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      const Text('প্রতিদিনের ওভারটাইম লিখুন', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: ink)),
      const SizedBox(height: 6),
      const Text('শুরুর বা শেষের সময় নয়—শুধু OT ঘণ্টা ও মিনিট লিখুন।'),
      const SizedBox(height: 18),
      Card(child: ListTile(
        leading: const Icon(Icons.calendar_month, color: pink),
        title: const Text('তারিখ'),
        subtitle: Text(DateFormat('dd MMMM yyyy').format(date)),
        trailing: const Icon(Icons.edit_calendar, color: pink),
        onTap: () async {
          final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2100));
          if (picked != null) setState(() => date = picked);
        },
      )),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _field('ঘণ্টা', hours, number: true)),
        const SizedBox(width: 12),
        Expanded(child: _field('অতিরিক্ত মিনিট (০–৫৯)', minutes, number: true)),
      ]),
      const SizedBox(height: 12),
      _field('প্রতি ঘণ্টার OT রেট (৳)', rate, number: true),
      const SizedBox(height: 12),
      _field('নোট (ঐচ্ছিক)', note, number: false),
      const SizedBox(height: 18),
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: softPink, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('আনুমানিক OT আয়', style: TextStyle(color: ink)),
        const SizedBox(height: 5),
        Text('৳${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: pink)),
        const Text('হিসাব = মোট মিনিট ÷ ৬০ × ঘণ্টাপ্রতি রেট', style: TextStyle(fontSize: 12)),
      ])),
      const SizedBox(height: 18),
      FilledButton(onPressed: saving ? null : save, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)), child: Text(saving ? 'সংরক্ষণ হচ্ছে…' : 'OT হিসাব সংরক্ষণ')),
    ]),
  );

  Widget _field(String label, TextEditingController controller, {required bool number}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    const SizedBox(height: 7),
    TextField(controller: controller, keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text, onChanged: (_) => setState(() {}), decoration: InputDecoration(hintText: label)),
  ]);
}
