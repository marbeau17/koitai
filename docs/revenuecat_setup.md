# RevenueCat セットアップガイド

KoiTai（コイタイ）のサブスクリプション機能は RevenueCat を使用して管理されています。
本ガイドでは、RevenueCat ダッシュボードの設定から、アプリへの組み込み、テスト方法までを説明します。

---

## 1. RevenueCat アカウント作成

1. [https://app.revenuecat.com](https://app.revenuecat.com) にアクセス
2. 「Sign Up」からアカウントを作成（Google / GitHub 連携も可能）
3. メール認証を完了してダッシュボードにログイン

---

## 2. プロジェクト作成

1. ダッシュボード左上の「Projects」から「+ New Project」をクリック
2. プロジェクト名: **KoiTai** と入力
3. 「Create Project」をクリック

---

## 3. Android アプリの追加

1. プロジェクト設定 > 「Apps」 > 「+ New App」
2. プラットフォーム: **Google Play Store** を選択
3. パッケージ名: `com.koitai.app`
4. 「Save」で保存
5. 表示される **Public API Key**（`goog_` で始まる文字列）をコピー

> このキーを後述の設定ファイルに記入します。

---

## 4. iOS アプリの追加

1. プロジェクト設定 > 「Apps」 > 「+ New App」
2. プラットフォーム: **App Store** を選択
3. Bundle ID: `com.koitai.app`
4. 「Save」で保存
5. 表示される **Public API Key**（`appl_` で始まる文字列）をコピー

> このキーを後述の設定ファイルに記入します。

---

## 5. Entitlement（資格）の作成

1. サイドバー「Entitlements」を開く
2. 「+ New Entitlement」をクリック
3. 設定内容:
   - **Identifier**: `premium`
   - **Description**: プレミアムプラン（全機能アクセス）
4. 「Save」で保存

---

## 6. Offering（オファリング）の作成

1. サイドバー「Offerings」を開く
2. 「+ New Offering」をクリック
3. 設定内容:
   - **Identifier**: `default`
   - **Description**: デフォルトオファリング
4. 「Save」で保存
5. この Offering を **Current Offering** に設定

---

## 7. Product（商品）の作成

### 7a. RevenueCat 上の商品登録

1. サイドバー「Products」を開く
2. 「+ New Product」をクリック
3. 設定内容:
   - **Identifier**: `koitai_monthly_680`
   - **Store**: App Store / Google Play（両方に作成）
   - **Type**: Auto-Renewable Subscription（自動更新サブスクリプション）
4. 「Save」で保存

### 7b. Offering への商品割り当て

1. 「Offerings」 > `default` を開く
2. 「+ New Package」をクリック
3. パッケージタイプ: **Monthly** を選択
4. 先ほど作成した `koitai_monthly_680` 商品を割り当て
5. 「Save」で保存

### 7c. 年額プランの追加（任意）

1. 同様に `love_timing_premium_yearly` 商品を作成（年額 ¥5,400）
2. Offering `default` に **Annual** パッケージとして割り当て

---

## 8. Google Play Console との連携

RevenueCat が Google Play のサブスクリプション情報を取得するために、サービスアカウントの設定が必要です。

### 手順:

1. [Google Cloud Console](https://console.cloud.google.com) にアクセス
2. プロジェクトを選択（Firebase プロジェクトと同じもの）
3. 「IAM と管理」 > 「サービスアカウント」 > 「+ サービスアカウントを作成」
4. 名前: `revenuecat-integration`
5. 役割: なし（後で Google Play Console 側で設定）
6. 「キーを作成」 > **JSON** 形式でダウンロード

### Google Play Console 側:

1. [Google Play Console](https://play.google.com/console) にアクセス
2. 「設定」 > 「APIアクセス」
3. 先ほどのサービスアカウントをリンク
4. 権限: 「財務データの表示」「注文と定期購入の管理」を有効化

### RevenueCat 側:

1. RevenueCat ダッシュボード > プロジェクト設定 > Android アプリ
2. 「Service Account Credentials」にダウンロードした JSON ファイルをアップロード
3. 「Save」で保存

### Google Play での商品作成:

1. Google Play Console > アプリ > 「収益化」 > 「定期購入」
2. 商品 ID: `koitai_monthly_680`
3. 価格: ¥680/月
4. 試用期間: 3日間（任意）

---

## 9. App Store Connect との連携

### Shared Secret の取得:

1. [App Store Connect](https://appstoreconnect.apple.com) にアクセス
2. アプリを選択 > 「App 情報」 > 「App 用共有シークレット」
3. 「生成」をクリックし、表示されたシークレットをコピー

### RevenueCat 側:

1. RevenueCat ダッシュボード > プロジェクト設定 > iOS アプリ
2. 「App Store Connect App-Specific Shared Secret」に貼り付け
3. 「Save」で保存

### App Store Connect での商品作成:

1. App Store Connect > アプリ > 「サブスクリプション」
2. サブスクリプショングループを作成: 「KoiTai Premium」
3. 商品 ID: `koitai_monthly_680`
4. 価格: ¥680/月（Tier 相当）
5. 試用期間: 3日間（任意）
6. ローカリゼーション:
   - 表示名: コイタイ プレミアム（月額）
   - 説明: 全占術の詳細結果、ペア占い無制限、広告非表示

---

## 10. APIキーの設定

取得した API キーをアプリのソースコードに設定します。

### 設定ファイル: `lib/core/constants/app_config.dart`

以下のプレースホルダーを実際のキーに置き換えてください:

```dart
// ── Subscription (RevenueCat) ────────────────────────────
static const String revenueCatApiKeyAndroid =
    'goog_YOUR_ACTUAL_ANDROID_API_KEY';  // ← ここを変更
static const String revenueCatApiKeyiOS =
    'appl_YOUR_ACTUAL_IOS_API_KEY';      // ← ここを変更
static const String revenueCatEntitlementId = 'premium';
static const String revenueCatOffering = 'default';
static const String monthlyProductId = 'koitai_monthly_680';
```

> **重要**: API キーは **Public API Key** です。秘密にする必要はありませんが、
> ソースコードを公開リポジトリに置く場合は環境変数等での管理を検討してください。

---

## 11. テスト方法

### iOS（Sandbox テスト）

1. App Store Connect > 「ユーザーとアクセス」 > 「Sandbox」 > 「テスター」
2. テスト用の Apple ID を作成
3. iOS 実機の「設定」 > 「App Store」 > 「サンドボックスアカウント」にサインイン
4. アプリをインストールし、サブスクリプション購入を実行
5. Sandbox 環境では更新間隔が短縮されます:
   - 月額 → 5分で自動更新
   - 年額 → 1時間で自動更新
   - 最大6回の自動更新後に停止

### Android（ライセンステスト）

1. Google Play Console > 「設定」 > 「ライセンステスト」
2. テスターの Gmail アドレスを追加
3. アプリを内部テストトラックにアップロード
4. テスターのアカウントでインストール
5. サブスクリプション購入を実行
6. テストカードで購入（実際の課金は発生しません）

### RevenueCat ダッシュボードでの確認

1. 「Customers」タブでテスト購入の状況を確認
2. 「Overview」でリアルタイムのイベントログを確認
3. Sandbox / テスト購入は「Sandbox」ラベルで表示されます

---

## 12. チェックリスト

リリース前に以下を確認してください:

- [ ] RevenueCat の API キーが本番用に設定されている
- [ ] Entitlement `premium` が正しく作成されている
- [ ] Offering `default` が Current Offering に設定されている
- [ ] 商品 `koitai_monthly_680` が各ストアで作成・審査済み
- [ ] Google Play のサービスアカウント JSON がアップロードされている
- [ ] App Store Connect の Shared Secret が設定されている
- [ ] Sandbox / ライセンステストで購入・復元・解約が動作する
- [ ] アプリ内に「購入を復元」ボタンが設置されている（Apple 審査要件）
- [ ] アプリ内に「アカウント削除」機能が設置されている（両ストア審査要件）
- [ ] 利用規約・プライバシーポリシーのリンクが設置されている

---

## トラブルシューティング

### 「利用可能なプランがありません」エラー

- RevenueCat の Offering `default` が Current Offering に設定されているか確認
- 商品がストア側で「承認済み」ステータスになっているか確認
- ストアとの連携（サービスアカウント / Shared Secret）が正しいか確認

### 購入後にプレミアムが反映されない

- Entitlement `premium` に商品が正しく紐付けられているか確認
- RevenueCat ダッシュボードの Customers タブで購入履歴を確認

### 「ストアが設定されていません」エラー

- `app_config.dart` の API キーがプレースホルダーのままになっていないか確認
- キーが正しいプラットフォーム用のものか確認（`goog_` = Android, `appl_` = iOS）
