import 'package:cloud_firestore/cloud_firestore.dart';

class NumerologyCompatibility {
  final int score;
  final int myLifePath;
  final int partnerLifePath;
  final String interpretation;

  const NumerologyCompatibility({
    required this.score,
    required this.myLifePath,
    required this.partnerLifePath,
    required this.interpretation,
  });

  factory NumerologyCompatibility.fromMap(Map<String, dynamic> map) {
    return NumerologyCompatibility(
      score: map['score'] as int? ?? 0,
      myLifePath: map['myLifePath'] as int? ?? 0,
      partnerLifePath: map['partnerLifePath'] as int? ?? 0,
      interpretation: map['interpretation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'myLifePath': myLifePath,
      'partnerLifePath': partnerLifePath,
      'interpretation': interpretation,
    };
  }
}

class BiorhythmSync {
  final int physicalSync;
  final int emotionalSync;
  final int intellectualSync;

  const BiorhythmSync({
    required this.physicalSync,
    required this.emotionalSync,
    required this.intellectualSync,
  });

  factory BiorhythmSync.fromMap(Map<String, dynamic> map) {
    return BiorhythmSync(
      physicalSync: map['physicalSync'] as int? ?? 0,
      emotionalSync: map['emotionalSync'] as int? ?? 0,
      intellectualSync: map['intellectualSync'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'physicalSync': physicalSync,
      'emotionalSync': emotionalSync,
      'intellectualSync': intellectualSync,
    };
  }
}

class BestDate {
  final String date;
  final int score;
  final String reason;

  const BestDate({
    required this.date,
    required this.score,
    required this.reason,
  });

  factory BestDate.fromMap(Map<String, dynamic> map) {
    return BestDate(
      date: map['date'] as String? ?? '',
      score: map['score'] as int? ?? 0,
      reason: map['reason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'score': score,
      'reason': reason,
    };
  }
}

class PairReadingModel {
  final String id;
  final String partnerName;
  final DateTime partnerBirthDate;
  final int compatibilityScore;
  final NumerologyCompatibility numerologyCompatibility;
  final BiorhythmSync biorhythmSync;
  final List<BestDate> bestDates;
  final String? nextBestDate;
  final String advice;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PairReadingModel({
    required this.id,
    required this.partnerName,
    required this.partnerBirthDate,
    required this.compatibilityScore,
    required this.numerologyCompatibility,
    required this.biorhythmSync,
    required this.bestDates,
    this.nextBestDate,
    required this.advice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PairReadingModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final bestDatesRaw = data['bestDates'] as List<dynamic>? ?? [];

    return PairReadingModel(
      id: doc.id,
      partnerName: data['partnerName'] as String? ?? '',
      partnerBirthDate: (data['partnerBirthDate'] as Timestamp).toDate(),
      compatibilityScore: data['compatibilityScore'] as int? ?? 0,
      numerologyCompatibility: NumerologyCompatibility.fromMap(
          data['numerologyCompatibility'] as Map<String, dynamic>? ?? {}),
      biorhythmSync: BiorhythmSync.fromMap(
          data['biorhythmSync'] as Map<String, dynamic>? ?? {}),
      bestDates: bestDatesRaw
          .map((e) => BestDate.fromMap(e as Map<String, dynamic>))
          .toList(),
      nextBestDate: data['nextBestDate'] as String?,
      advice: data['advice'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'partnerName': partnerName,
      'partnerBirthDate': Timestamp.fromDate(partnerBirthDate),
      'compatibilityScore': compatibilityScore,
      'numerologyCompatibility': numerologyCompatibility.toMap(),
      'biorhythmSync': biorhythmSync.toMap(),
      'bestDates': bestDates.map((e) => e.toMap()).toList(),
      'nextBestDate': nextBestDate,
      'advice': advice,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
