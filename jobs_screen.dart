import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/jobs_service.dart';
import 'home_screen.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('PLUS Jobs'), actions: [
      IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PostJobScreen())), icon: const Icon(Icons.add_box_outlined, color: pink)),
    ]),
    body: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 12), child: TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search, color: pink), hintText: 'পদ, প্রতিষ্ঠান বা এলাকা খুঁজুন', suffixIcon: IconButton(onPressed: () {}, icon: const Icon(Icons.tune))))),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Align(alignment: Alignment.centerLeft, child: Text('সাম্প্রতিক চাকরি', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)))),
      const SizedBox(height: 8),
      Expanded(child: StreamBuilder<List<JobPost>>(
        stream: JobsService().publishedJobs(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('চাকরির তালিকা লোড করা যায়নি। Firebase কনফিগারেশন ও Rules পরীক্ষা করুন।')));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: pink));
          final jobs = snapshot.data ?? [];
          if (jobs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('এখনো প্রকাশিত চাকরি নেই। নিয়োগকর্তার পোস্ট যাচাই করে প্রকাশ করতে হবে।', textAlign: TextAlign.center)));
          return ListView.builder(padding: const EdgeInsets.all(14), itemCount: jobs.length, itemBuilder: (context, i) {
            final j = jobs[i];
            return Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [const CircleAvatar(backgroundColor: softPink, child: Icon(Icons.factory_outlined, color: pink)), const SizedBox(width: 10), Expanded(child: Text(j.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))), const Icon(Icons.verified_outlined, color: Colors.blueGrey)]),
              const SizedBox(height: 8),
              Text(j.company, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('${j.location} • ${j.category}'),
              const SizedBox(height: 5),
              Text('বেতন: ${j.salary}', style: const TextStyle(color: pink, fontWeight: FontWeight.bold)),
              if (j.description.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(j.description, maxLines: 3, overflow: TextOverflow.ellipsis)),
            ])));
          });
        },
      )),
    ]),
  );
}

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});
  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final title = TextEditingController();
  final company = TextEditingController();
  final location = TextEditingController();
  final salary = TextEditingController();
  final description = TextEditingController();
  String category = 'সুইং অপারেটর';
  bool busy = false;
  final categories = const ['সুইং অপারেটর', 'হেলপার', 'কোয়ালিটি', 'মার্চেন্ডাইজিং', 'IE', 'HR', 'কমপ্লায়েন্স', 'নিটিং', 'ডাইং', 'ফিনিশিং', 'অন্যান্য'];

  @override
  void dispose() { title.dispose(); company.dispose(); location.dispose(); salary.dispose(); description.dispose(); super.dispose(); }

  Future<void> submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('চাকরি পোস্ট করতে আগে লগইন ব্যবস্থা সেটআপ করতে হবে।')));
      return;
    }
    if ([title.text, company.text, location.text].any((v) => v.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('পদ, প্রতিষ্ঠান ও এলাকা পূরণ করুন।')));
      return;
    }
    setState(() => busy = true);
    try {
      await JobsService().postJob(uid: user.uid, title: title.text, company: company.text, location: location.text, salary: salary.text, category: category, description: description.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('চাকরির পোস্ট জমা হয়েছে; যাচাই শেষে প্রকাশ করা যাবে।')));
        Navigator.pop(context);
      }
    } on FirebaseException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('পোস্ট করা যায়নি: ${e.message ?? e.code}')));
    } finally { if (mounted) setState(() => busy = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('চাকরি পোস্ট করুন')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      const Text('নিয়োগের তথ্য দিন', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      _field('পদের নাম *', title),
      _field('প্রতিষ্ঠানের নাম *', company),
      _field('কর্মস্থল *', location),
      _field('বেতন', salary),
      const Text('ক্যাটাগরি'),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(value: category, items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => category = v ?? category)),
      const SizedBox(height: 12),
      _field('চাকরির বিস্তারিত', description, maxLines: 4),
      const SizedBox(height: 16),
      const Text('নিরাপত্তা: পোস্টটি প্রথমে pending থাকবে; যাচাই শেষে admin প্রকাশ করবে।', style: TextStyle(color: Colors.black54)),
      const SizedBox(height: 16),
      FilledButton(onPressed: busy ? null : submit, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)), child: Text(busy ? 'জমা হচ্ছে…' : 'চাকরির পোস্ট জমা দিন')),
    ]),
  );

  Widget _field(String label, TextEditingController c, {int maxLines = 1}) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    const SizedBox(height: 6),
    TextField(controller: c, maxLines: maxLines, decoration: InputDecoration(hintText: label)),
  ]));
}
