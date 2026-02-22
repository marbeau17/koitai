import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pair_reading_model.dart';

class PairRepository {
  final FirebaseFirestore _firestore;

  PairRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _pairCollection(String uid) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('pair_readings');

  /// Save a new pair reading result
  Future<PairReadingModel> savePairReading(
      String uid, PairReadingModel reading) async {
    final docRef = _pairCollection(uid).doc(reading.id);
    await docRef.set(reading.toFirestore());
    return reading;
  }

  /// Get all pair readings for a user, ordered by creation date descending
  Future<List<PairReadingModel>> getPairReadings(String uid) async {
    final snapshot = await _pairCollection(uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PairReadingModel.fromFirestore(doc))
        .toList();
  }

  /// Get a single pair reading
  Future<PairReadingModel?> getPairReading(String uid, String pairId) async {
    final doc = await _pairCollection(uid).doc(pairId).get();
    if (!doc.exists) return null;
    return PairReadingModel.fromFirestore(doc);
  }

  /// Delete a pair reading
  Future<void> deletePairReading(String uid, String pairId) async {
    await _pairCollection(uid).doc(pairId).delete();
  }
}
