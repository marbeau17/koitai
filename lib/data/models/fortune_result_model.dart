import 'package:cloud_firestore/cloud_firestore.dart';

class NumerologyDetail {
  final int personalDay;
  final int universalDay;
  final String interpretation;

  const NumerologyDetail({
    required this.personalDay,
    required this.universalDay,
    required this.interpretation,
  });

  factory NumerologyDetail.fromMap(Map<String, dynamic> map) {
    return NumerologyDetail(
      personalDay: map['personalDay'] as int? ?? 0,
      universalDay: map['universalDay'] as int? ?? 0,
      interpretation: map['interpretation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'personalDay': personalDay,
      'universalDay': universalDay,
      'interpretation': interpretation,
    };
  }
}

class MoonPhaseDetail {
  final String phase;
  final double illumination;
  final double moonAge;
  final String interpretation;

  const MoonPhaseDetail({
    required this.phase,
    required this.illumination,
    required this.moonAge,
    required this.interpretation,
  });

  factory MoonPhaseDetail.fromMap(Map<String, dynamic> map) {
    return MoonPhaseDetail(
      phase: map['phase'] as String? ?? 'new',
      illumination: (map['illumination'] as num?)?.toDouble() ?? 0.0,
      moonAge: (map['moonAge'] as num?)?.toDouble() ?? 0.0,
      interpretation: map['interpretation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phase': phase,
      'illumination': illumination,
      'moonAge': moonAge,
      'interpretation': interpretation,
    };
  }
}

class BiorhythmDetail {
  final double physical;
  final double emotional;
  final double intellectual;
  final String interpretation;

  const BiorhythmDetail({
    required this.physical,
    required this.emotional,
    required this.intellectual,
    required this.interpretation,
  });

  factory BiorhythmDetail.fromMap(Map<String, dynamic> map) {
    return BiorhythmDetail(
      physical: (map['physical'] as num?)?.toDouble() ?? 0.0,
      emotional: (map['emotional'] as num?)?.toDouble() ?? 0.0,
      intellectual: (map['intellectual'] as num?)?.toDouble() ?? 0.0,
      interpretation: map['interpretation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'physical': physical,
      'emotional': emotional,
      'intellectual': intellectual,
      'interpretation': interpretation,
    };
  }
}

class FortuneResultModel {
  final String date;
  final int overallScore;
  final int numerologyScore;
  final int moonPhaseScore;
  final int biorhythmScore;
  final NumerologyDetail numerologyDetail;
  final MoonPhaseDetail moonPhaseDetail;
  final BiorhythmDetail biorhythmDetail;
  final String advice;
  final String luckyTime;
  final String luckyColor;
  final bool isTopDay;
  final String rank;
  final DateTime? calculatedAt;

  const FortuneResultModel({
    required this.date,
    required this.overallScore,
    required this.numerologyScore,
    required this.moonPhaseScore,
    required this.biorhythmScore,
    required this.numerologyDetail,
    required this.moonPhaseDetail,
    required this.biorhythmDetail,
    required this.advice,
    required this.luckyTime,
    required this.luckyColor,
    this.isTopDay = false,
    required this.rank,
    this.calculatedAt,
  });

  factory FortuneResultModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FortuneResultModel(
      date: data['date'] as String? ?? doc.id,
      overallScore: data['overallScore'] as int? ?? 0,
      numerologyScore: data['numerologyScore'] as int? ?? 0,
      moonPhaseScore: data['moonPhaseScore'] as int? ?? 0,
      biorhythmScore: data['biorhythmScore'] as int? ?? 0,
      numerologyDetail: NumerologyDetail.fromMap(
          data['numerologyDetail'] as Map<String, dynamic>? ?? {}),
      moonPhaseDetail: MoonPhaseDetail.fromMap(
          data['moonPhaseDetail'] as Map<String, dynamic>? ?? {}),
      biorhythmDetail: BiorhythmDetail.fromMap(
          data['biorhythmDetail'] as Map<String, dynamic>? ?? {}),
      advice: data['advice'] as String? ?? '',
      luckyTime: data['luckyTime'] as String? ?? '',
      luckyColor: data['luckyColor'] as String? ?? '',
      isTopDay: data['isTopDay'] as bool? ?? false,
      rank: data['rank'] as String? ?? 'C',
      calculatedAt: (data['calculatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory FortuneResultModel.fromMap(Map<String, dynamic> data) {
    return FortuneResultModel(
      date: data['date'] as String? ?? '',
      overallScore: data['overallScore'] as int? ?? 0,
      numerologyScore: data['numerologyScore'] as int? ?? 0,
      moonPhaseScore: data['moonPhaseScore'] as int? ?? 0,
      biorhythmScore: data['biorhythmScore'] as int? ?? 0,
      numerologyDetail: NumerologyDetail.fromMap(
          data['numerologyDetail'] as Map<String, dynamic>? ?? {}),
      moonPhaseDetail: MoonPhaseDetail.fromMap(
          data['moonPhaseDetail'] as Map<String, dynamic>? ?? {}),
      biorhythmDetail: BiorhythmDetail.fromMap(
          data['biorhythmDetail'] as Map<String, dynamic>? ?? {}),
      advice: data['advice'] as String? ?? '',
      luckyTime: data['luckyTime'] as String? ?? '',
      luckyColor: data['luckyColor'] as String? ?? '',
      isTopDay: data['isTopDay'] as bool? ?? false,
      rank: data['rank'] as String? ?? 'C',
      calculatedAt: data['calculatedAt'] != null
          ? (data['calculatedAt'] is Timestamp
              ? (data['calculatedAt'] as Timestamp).toDate()
              : DateTime.parse(data['calculatedAt'] as String))
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': date,
      'overallScore': overallScore,
      'numerologyScore': numerologyScore,
      'moonPhaseScore': moonPhaseScore,
      'biorhythmScore': biorhythmScore,
      'numerologyDetail': numerologyDetail.toMap(),
      'moonPhaseDetail': moonPhaseDetail.toMap(),
      'biorhythmDetail': biorhythmDetail.toMap(),
      'advice': advice,
      'luckyTime': luckyTime,
      'luckyColor': luckyColor,
      'isTopDay': isTopDay,
      'rank': rank,
      'calculatedAt': Timestamp.fromDate(calculatedAt ?? DateTime.now()),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'overallScore': overallScore,
      'numerologyScore': numerologyScore,
      'moonPhaseScore': moonPhaseScore,
      'biorhythmScore': biorhythmScore,
      'numerologyDetail': numerologyDetail.toMap(),
      'moonPhaseDetail': moonPhaseDetail.toMap(),
      'biorhythmDetail': biorhythmDetail.toMap(),
      'advice': advice,
      'luckyTime': luckyTime,
      'luckyColor': luckyColor,
      'isTopDay': isTopDay,
      'rank': rank,
      'calculatedAt': calculatedAt?.toIso8601String(),
    };
  }
}
