import 'biorhythm_service.dart';
import 'love_timing_service.dart';
import 'moon_phase_service.dart';
import 'numerology_service.dart';

/// Daily fortune advice result.
class DailyAdvice {
  final String mainText;
  final String luckyColor;
  final String luckyTime;
  final String luckySpot;
  final List<LoveAction> actions;

  const DailyAdvice({
    required this.mainText,
    required this.luckyColor,
    required this.luckyTime,
    required this.luckySpot,
    required this.actions,
  });
}

/// Generates fortune text based on score, moon phase, and numerology.
class FortuneTextService {
  // -- Lucky color table (by personal day number) --
  static const Map<int, String> luckyColorTable = {
    1: 'レッド',
    2: 'オレンジ',
    3: 'イエロー',
    4: 'グリーン',
    5: 'ターコイズ',
    6: 'ピンク',
    7: 'パープル',
    8: 'ゴールド',
    9: 'ホワイト',
    11: 'シルバー',
    22: 'ネイビー',
    33: 'ローズゴールド',
  };

  // -- Lucky time table (by personal day number) --
  static const Map<int, String> luckyTimeTable = {
    1: '朝6〜8時',
    2: '午前10〜12時',
    3: '午後1〜3時',
    4: '午後3〜5時',
    5: '午後5〜7時',
    6: '夕方6〜8時',
    7: '夜8〜10時',
    8: '午後12〜2時',
    9: '夜9〜11時',
    11: '午前11時11分',
    22: '午後10時22分',
    33: '午後3時33分',
  };

  // -- Lucky spot table (by moon phase) --
  static const Map<MoonPhase, String> luckySpotTable = {
    MoonPhase.newMoon: 'おしゃれなカフェ',
    MoonPhase.waxingCrescent: '公園・自然の中',
    MoonPhase.firstQuarter: 'アクティビティスポット',
    MoonPhase.waxingGibbous: 'レストラン・バー',
    MoonPhase.fullMoon: '夜景スポット・展望台',
    MoonPhase.waningGibbous: '美術館・博物館',
    MoonPhase.lastQuarter: '図書館・書店',
    MoonPhase.waningCrescent: '温泉・スパ',
  };

  // -- Action labels --
  static const Map<LoveAction, String> _actionLabels = {
    LoveAction.confession: '告白',
    LoveAction.proposal: 'プロポーズ',
    LoveAction.askForDate: 'デートのお誘い',
    LoveAction.sendMessage: 'メッセージ送信',
    LoveAction.exchangeContact: '連絡先交換',
    LoveAction.reviewRelation: '関係の見直し',
    LoveAction.selfImprovement: '自分磨き',
  };

  // -- 5-star templates (85-100) --
  static const List<String> _templates5Star = [
    '今日は恋愛運が最高潮! {moonPhase}のパワーがあなたの魅力を最大限に引き出します。{topAction}には絶好のタイミング!',
    '宇宙があなたの恋を全力で応援する日。スコア{score}点! 勇気を出して一歩踏み出して。',
    '運命が大きく動く予感。今日の{moonPhase}はあなたの想いを相手に届ける最高のタイミングです。',
    '{userName}さんの恋愛パワーが頂点に! 数秘{personalDay}のエネルギーが後押しします。迷わず行動して!',
    '今日逃したらもったいない! 恋愛運{score}点の奇跡の日。{topAction}のチャンスを見逃さないで。',
    '星が5つ揃う特別な日。あなたの魅力が輝き、相手のハートを掴むベストタイミング!',
    '恋の女神が微笑む日。{moonPhase}と数秘のパワーが完璧にシンクロしています。',
    '今日のあなたは無敵! 自信を持って。{topAction}をするなら今日しかありません。',
    '恋愛運スコア{score}点! こんな日はめったにない。直感を信じて行動してみて。',
    '宇宙の全てがあなたの恋を祝福する一日。{luckyColor}のアイテムを身につけて最高の結果を!',
  ];

  // -- 4-star templates (70-84) --
  static const List<String> _templates4Star = [
    '恋愛運好調! {moonPhase}のエネルギーが心地よく流れています。{topAction}に好タイミング。',
    '今日のあなたは魅力的。スコア{score}点で、さりげないアプローチが効果的な日。',
    '数秘{personalDay}のパワーで、コミュニケーションが円滑に。気になる人との距離が縮まりそう。',
    'いい流れが来ています。焦らなくても自然体でOK。{topAction}をしてみて。',
    '{moonPhase}のおかげで感受性が高まる日。相手の気持ちを敏感に感じ取れるはず。',
    '恋の追い風が吹いています。{luckyTime}頃に動くとさらにGood!',
    '今日は恋愛に積極的になれる日。自分からアクションを起こすと良い反応が返ってくるかも。',
    '心が温かくなる出来事がありそう。オープンマインドで過ごして。',
    '恋愛運{score}点。普段できないことに挑戦するのに良い日。{topAction}を試してみて。',
    'バイオリズムが好調! 感情表現が豊かになるので、素直な気持ちを伝えてみて。',
  ];

  // -- 3-star templates (50-69) --
  static const List<String> _templates3Star = [
    '恋愛運は平穏。大きなアクションよりも、日常の中のさりげない優しさが効果的。',
    '焦らない日。{moonPhase}のリズムに身を任せて、自然体で過ごしましょう。',
    '今日は準備の日。次の好タイミングに向けて、自分の魅力を磨いておこう。',
    'スコア{score}点。悪くはないけど、大勝負は避けて。小さなアプローチを積み重ねて。',
    '数秘{personalDay}は地道な努力が実る数字。コツコツとした愛情表現が吉。',
    '相手をよく観察する日にしよう。今日得た情報が、後の好タイミングで活きてくるはず。',
    'リラックスして過ごすのが一番。無理せず、でも{topAction}くらいならOK。',
    '恋愛運はニュートラル。今日は友人との時間を楽しんで、恋愛のヒントをもらおう。',
    '{luckyColor}のアイテムでさりげなく運気アップ。小さな工夫が明日につながります。',
    'バイオリズムが安定期。穏やかなコミュニケーションを心がけてみて。',
  ];

  // -- 2-star templates (30-49) --
  static const List<String> _templates2Star = [
    '今日は控えめに。{moonPhase}の影響で判断が鈍りやすいので、重要な決断は延期して。',
    '恋愛運やや低め。でも大丈夫、この時期を過ごすからこそ、次の好運期が輝く。',
    '自分の内面と向き合う日。理想のパートナー像を改めて考えてみよう。',
    'スコア{score}点。少しお休みモード。無理にアクションを起こさなくてOK。',
    'バイオリズムが低めの日。体と心を休めることも大切な恋愛スキル。',
    '今日はSNSでの発信は控えめに。誤解を生みやすいタイミング。',
    '恋愛よりも自分の趣味や仕事に集中するのが吉。充実した自分が最大の魅力。',
    '{moonPhase}の影響で感情が揺れやすい日。冷静に、そして優しく。',
    '次の好タイミングは近い! 今日は充電日と思って、好きなことを楽しんで。',
    '焦りは禁物。恋愛は長い旅。今日一日で全てが決まるわけではありません。',
  ];

  // -- 1-star templates (0-29) --
  static const List<String> _templates1Star = [
    '今日は完全充電日! 自分を甘やかして。美味しいものを食べて、ゆっくり休んで。',
    '恋愛はお休み。でもこの充電が次の最高の日への準備になります。',
    '{moonPhase}の影響で内向的になりやすい日。一人の時間を大切にして。',
    'スコア{score}点。宇宙が「少し休んで」と言っている日。無理は禁物。',
    '今日は行動よりもインプットの日。恋愛本を読んだり、映画を観たりするのがおすすめ。',
    'バイオリズムが最低域。でも心配しないで、明日からまた上がっていきます。',
    '一人の時間は自分を知る最高の機会。次に動く時、もっと自信を持てるはず。',
    '静かな日こそ、自分の本当の望みが見えてくる。心の声に耳を傾けて。',
    '恋愛スコアは低めだけど、友情運は悪くない。友達と過ごすのもいい選択。',
    '今日は我慢の日。でもここを超えたら、きっと素敵なことが待っている!',
  ];

  // -- Pair timing templates --
  static const List<String> _templatesPairHigh = [
    '2人の運命が最高に輝く日! 宇宙があなたたちの恋を全力応援中。',
    '相性バツグンのタイミング! 今日2人で過ごす時間は特別な思い出になるはず。',
    '数秘の力が2人を引き寄せる日。心を開いて素直な気持ちを伝えて。',
  ];

  static const List<String> _templatesPairMid = [
    '2人の波長がまずまず合っている日。自然体で楽しい時間を過ごせそう。',
    'リラックスした雰囲気が2人の距離を縮める。気負わないのがポイント。',
    '少しずつ心を通わせるのに良い日。焦らずゆっくり。',
  ];

  static const List<String> _templatesPairLow = [
    '今日は2人のリズムがすれ違いやすい日。無理にデートするより別の日がベター。',
    'お互いの充電日。今日は個別に過ごして、次の好タイミングに備えよう。',
    '焦らないで。最高のタイミングは必ずやってくる。今は自分を磨く時間。',
  ];

  /// Selects a template based on the score band.
  static String _selectTemplate(int score, int seed) {
    final List<String> templates;
    if (score >= 85) {
      templates = _templates5Star;
    } else if (score >= 70) {
      templates = _templates4Star;
    } else if (score >= 50) {
      templates = _templates3Star;
    } else if (score >= 30) {
      templates = _templates2Star;
    } else {
      templates = _templates1Star;
    }
    final index = seed % templates.length;
    return templates[index];
  }

  /// Selects a pair timing template based on the score.
  static String selectPairTemplate(int pairScore, int seed) {
    final List<String> templates;
    if (pairScore >= 80) {
      templates = _templatesPairHigh;
    } else if (pairScore >= 50) {
      templates = _templatesPairMid;
    } else {
      templates = _templatesPairLow;
    }
    final index = seed % templates.length;
    return templates[index];
  }

  /// Replaces template variables with actual values.
  static String _applyVariables(
    String template, {
    required String userName,
    required int score,
    required int stars,
    required String moonPhaseName,
    required int personalDay,
    required String topAction,
    required String luckyColor,
    required String luckyTime,
  }) {
    return template
        .replaceAll('{userName}', userName)
        .replaceAll('{score}', score.toString())
        .replaceAll('{stars}', stars.toString())
        .replaceAll('{moonPhase}', moonPhaseName)
        .replaceAll('{personalDay}', personalDay.toString())
        .replaceAll('{topAction}', topAction)
        .replaceAll('{luckyColor}', luckyColor)
        .replaceAll('{luckyTime}', luckyTime);
  }

  /// Returns the action label in Japanese.
  static String getActionLabel(LoveAction action) {
    return _actionLabels[action] ?? '';
  }

  /// Generates a daily advice result for a user.
  ///
  /// The [seed] parameter controls template selection (typically derived from
  /// the date to ensure the same day always produces the same text).
  static DailyAdvice generateDailyAdvice({
    required DateTime birthDate,
    required DateTime targetDate,
    required String userName,
    int? seed,
  }) {
    final score =
        LoveTimingService.calculateTotalLoveScore(birthDate, targetDate);
    final stars = LoveTimingService.getStarRating(score);

    final moonAge = MoonPhaseService.calculateMoonAge(targetDate);
    final moonFraction = MoonPhaseService.calculateMoonFraction(moonAge);
    final moonPhase = MoonPhaseService.getMoonPhase(moonFraction);
    final moonPhaseName = MoonPhaseService.getMoonPhaseName(moonPhase);

    final personalYear =
        NumerologyService.calculatePersonalYear(birthDate, targetDate.year);
    final personalDay = NumerologyService.calculatePersonalDay(
        personalYear, targetDate.month, targetDate.day);

    final biorhythm =
        BiorhythmService.calculateBiorhythm(birthDate, targetDate);
    final actions = LoveTimingService.getRecommendedActions(
        score, moonFraction, biorhythm);

    final topAction =
        actions.isNotEmpty ? getActionLabel(actions.first) : '自分磨き';

    final luckyColor = luckyColorTable[personalDay] ?? 'ホワイト';
    final luckyTime = luckyTimeTable[personalDay] ?? '午後12時';
    final luckySpot = luckySpotTable[moonPhase] ?? 'おしゃれなカフェ';

    // Use date-based seed for daily consistency
    final effectiveSeed = seed ??
        (targetDate.year * 10000 +
            targetDate.month * 100 +
            targetDate.day);

    final template = _selectTemplate(score, effectiveSeed);
    final mainText = _applyVariables(
      template,
      userName: userName,
      score: score,
      stars: stars,
      moonPhaseName: moonPhaseName,
      personalDay: personalDay,
      topAction: topAction,
      luckyColor: luckyColor,
      luckyTime: luckyTime,
    );

    return DailyAdvice(
      mainText: mainText,
      luckyColor: luckyColor,
      luckyTime: luckyTime,
      luckySpot: luckySpot,
      actions: actions,
    );
  }
}
