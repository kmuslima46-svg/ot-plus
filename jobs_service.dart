import 'package:cloud_firestore/cloud_firestore.dart';

class JobPost {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String category;
  final String description;
  final bool isDemo;

  const JobPost({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.category,
    required this.description,
    this.isDemo = false,
  });

  factory JobPost.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return JobPost(
      id: doc.id,
      title: d['title'] ?? 'চাকরির পদ',
      company: d['company'] ?? 'প্রতিষ্ঠান',
      location: d['location'] ?? 'বাংলাদেশ',
      salary: d['salary'] ?? 'আলোচনা সাপেক্ষে',
      category: d['category'] ?? 'অন্যান্য',
      description: d['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap(String uid) => {
    'title': title,
    'company': company,
    'location': location,
    'salary': salary,
    'category': category,
    'description': description,
    'createdBy': uid,
    'createdAt': FieldValue.serverTimestamp(),
    'status': 'pending',
  };
}

class JobsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<JobPost>> publishedJobs() {
    return _db.collection('jobs')
      .where('status', isEqualTo: 'published')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map(JobPost.fromDoc).toList());
  }

  Future<void> postJob({
    required String uid,
    required String title,
    required String company,
    required String location,
    required String salary,
    required String category,
    required String description,
  }) async {
    await _db.collection('jobs').add(JobPost(
      id: '',
      title: title.trim(),
      company: company.trim(),
      location: location.trim(),
      salary: salary.trim(),
      category: category,
      description: description.trim(),
    ).toMap(uid));
  }
}
