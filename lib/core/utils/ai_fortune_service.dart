import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../domain/services/fortune_text_service.dart';
import '../../features/pair/providers/pair_provider.dart';
import '../constants/app_config.dart';

/// AI-generated fortune advice result.
class AiAdvice {
  final String advice;
  final String luckyColor;
  final String luckyTime;
  final String luckySpot;

  const AiAdvice({
    required this.advice,
    required this.luckyColor,
    required this.luckyTime,
    required this.luckySpot,
  });
}

/// Singleton service that uses Google Gemini to generate personalised fortune
/// advice. Falls back to template text on failure.
class AiFortuneService {
  AiFortuneService._();
  static final AiFortuneService _instance = AiFortuneService._();
  factory AiFortuneService() => _instance;

  /// Creates a [GenerativeModel] with the given [systemInstruction].
  GenerativeModel _createModel(Content systemInstruction) {
    return GenerativeModel(
      model: AppConfig.geminiModel,
      apiKey: AppConfig.geminiApiKey,
      systemInstruction: systemInstruction,
    );
  }

  // ── Daily advice ──────────────────────────────────────────

  /// Generates AI-powered daily love fortune advice.
  ///
  /// On any failure the method falls back to [FortuneTextService] template
  /// text so the user always sees *something*.
  Future<AiAdvice> generateDailyAdvice({
    required int overallScore,
    required int numerologyScore,
    required int moonScore,
    required int biorhythmScore,
    required String moonPhaseName,
    required String biorhythmPhase,
    required DateTime birthDate,
    required DateTime targetDate,
  }) async {
    try {
      final systemPrompt = Content.system(
        'あなたは「コイタイ」という恋愛タイミング占いアプリの占い師です。\n'
        'ユーザーの占いデータに基づいて、温かく親しみやすい日本語でアドバイスを生成してください。\n'
        '以下のルールを守ってください：\n'
        '- 3〜4文で簡潔にまとめる\n'
        '- 具体的な行動アドバイスを1つ含める\n'
        '- 月の満ち欠けやバイオリズムに触れる\n'
        '- ポジティブで励ましのトーンで\n'
        '- 絵文字は使わない\n'
        '- 「ラッキーカラー」「ラッキータイム」「ラッキースポット」も1つずつ提案する\n'
        '- 以下のJSON形式で返答してください：\n'
        '{"advice": "メインアドバイス文", "luckyColor": "色", "luckyTime": "時間帯", "luckySpot": "場所"}',
      );

      final formattedDate =
          '${targetDate.year}年${targetDate.month}月${targetDate.day}日';

      final userPrompt = '【占いデータ】\n'
          '総合スコア: $overallScore点\n'
          '数秘術スコア: $numerologyScore点\n'
          '月齢スコア: $moonScore点\n'
          'バイオリズムスコア: $biorhythmScore点\n'
          '月相: $moonPhaseName\n'
          'バイオリズム状態: $biorhythmPhase\n'
          '日付: $formattedDate';

      final model = _createModel(systemPrompt);
      final response = await model
          .generateContent([Content.text(userPrompt)])
          .timeout(const Duration(seconds: 10));

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Empty response from Gemini');
      }

      return _parseDailyResponse(text);
    } catch (e) {
      debugPrint('AiFortuneService.generateDailyAdvice error: $e');

      // Fallback to template text.
      final fallback = FortuneTextService.generateDailyAdvice(
        birthDate: birthDate,
        targetDate: targetDate,
        userName: 'あなた',
      );
      return AiAdvice(
        advice: fallback.mainText,
        luckyColor: fallback.luckyColor,
        luckyTime: fallback.luckyTime,
        luckySpot: fallback.luckySpot,
      );
    }
  }

  /// Attempts to parse the Gemini JSON response. Falls back to treating the
  /// entire text as the advice field.
  AiAdvice _parseDailyResponse(String raw) {
    try {
      // Strip markdown code fences if present.
      var cleaned = raw.trim();
      if (cleaned.startsWith('```')) {
        cleaned = cleaned
            .replaceFirst(RegExp(r'^```[a-zA-Z]*\n?'), '')
            .replaceFirst(RegExp(r'\n?```$'), '');
      }
      final map = json.decode(cleaned) as Map<String, dynamic>;
      return AiAdvice(
        advice: (map['advice'] as String?) ?? cleaned,
        luckyColor: (map['luckyColor'] as String?) ?? '',
        luckyTime: (map['luckyTime'] as String?) ?? '',
        luckySpot: (map['luckySpot'] as String?) ?? '',
      );
    } catch (_) {
      // If JSON parsing fails, return the raw text as advice.
      return AiAdvice(
        advice: raw.trim(),
        luckyColor: '',
        luckyTime: '',
        luckySpot: '',
      );
    }
  }

  // ── Pair advice ───────────────────────────────────────────

  /// Generates AI-powered pair compatibility advice.
  ///
  /// Returns a plain advice string. On failure falls back to the template
  /// service.
  Future<String> generatePairAdvice({
    required int compatibilityScore,
    required int numerologyScore,
    required int moonSyncScore,
    required int biorhythmScore,
    required List<RecommendedDate> recommendedDates,
  }) async {
    try {
      final systemPrompt = Content.system(
        'あなたは「コイタイ」という恋愛タイミング占いアプリの占い師です。\n'
        '2人の相性占いデータに基づいて、温かく親しみやすい日本語でアドバイスを生成してください。\n'
        '以下のルールを守ってください：\n'
        '- 3〜4文で簡潔にまとめる\n'
        '- 2人の相性の良い点と、関係を深めるための具体的なアドバイスを含める\n'
        '- おすすめのデートアクティビティを1つ提案する\n'
        '- ポジティブで励ましのトーンで\n'
        '- 絵文字は使わない\n'
        '- プレーンテキストで返答してください（JSON不要）',
      );

      final datesText = recommendedDates.map((d) {
        final formatted =
            '${d.date.year}年${d.date.month}月${d.date.day}日';
        return '$formatted (${d.score}点) - ${d.label}';
      }).join('\n');

      final userPrompt = '【ペア占いデータ】\n'
          '相性スコア: $compatibilityScore点\n'
          '数秘術相性: $numerologyScore点\n'
          '月齢シンクロ: $moonSyncScore点\n'
          'バイオリズム同期: $biorhythmScore点\n'
          '\n'
          '【おすすめデート日】\n'
          '$datesText';

      final model = _createModel(systemPrompt);
      final response = await model
          .generateContent([Content.text(userPrompt)])
          .timeout(const Duration(seconds: 10));

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Empty response from Gemini');
      }
      return text.trim();
    } catch (e) {
      debugPrint('AiFortuneService.generatePairAdvice error: $e');

      // Fallback to template.
      final seed = DateTime.now().millisecondsSinceEpoch;
      return FortuneTextService.selectPairTemplate(compatibilityScore, seed);
    }
  }
}
