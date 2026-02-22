import 'package:cloud_firestore/cloud_firestore.dart';

import '../datasources/local_storage_datasource.dart';
import '../models/fortune_result_model.dart';

class FortuneRepository {
  final FirebaseFirestore _firestore;
  final LocalStorageDatasource _localStorage;

  FortuneRepository({
    FirebaseFirestore? firestore,
    required LocalStorageDatasource localStorage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _localStorage = localStorage;

  DocumentReference<Map<String, dynamic>> _fortuneDoc(
          String uid, String date) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('fortune_results')
          .doc(date);

  CollectionReference<Map<String, dynamic>> _fortuneCollection(String uid) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('fortune_results');

  /// Get daily fortune: local cache -> Firestore
  Future<FortuneResultModel?> getDailyFortune(String uid, String date) async {
    // L2 cache (Hive)
    final cached = _localStorage.getFortune(date);
    if (cached != null) return cached;

    // L3 Firestore
    final doc = await _fortuneDoc(uid, date).get();
    if (!doc.exists) return null;

    final fortune = FortuneResultModel.fromFirestore(doc);
    await _localStorage.saveFortune(fortune);
    return fortune;
  }

  /// Save fortune result to Firestore and local cache
  Future<void> saveDailyFortune(String uid, FortuneResultModel fortune) async {
    await _fortuneDoc(uid, fortune.date).set(fortune.toFirestore());
    await _localStorage.saveFortune(fortune);
  }

  /// Get monthly fortunes for calendar view
  Future<List<FortuneResultModel>> getMonthlyFortunes(
      String uid, int year, int month) async {
    // Try local cache first
    final cached = await _localStorage.getMonthlyFortunes(year, month);
    if (cached.isNotEmpty) return cached;

    // Query Firestore
    final monthStr = month.toString().padLeft(2, '0');
    final startDate = '$year-$monthStr-01';
    final endMonth = month == 12 ? 1 : month + 1;
    final endYear = month == 12 ? year + 1 : year;
    final endDate = '$endYear-${endMonth.toString().padLeft(2, '0')}-01';

    final snapshot = await _fortuneCollection(uid)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThan: endDate)
        .orderBy('date')
        .get();

    final results =
        snapshot.docs.map((d) => FortuneResultModel.fromFirestore(d)).toList();

    // Cache all results locally
    for (final fortune in results) {
      await _localStorage.saveFortune(fortune);
    }

    return results;
  }
}
