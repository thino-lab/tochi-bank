# 土地バンク アーキテクチャ方針

土地バンクは「住宅会社が持つ土地情報を一元管理し、お客様に紹介して反応を受け取る」アプリ。
HTML を1枚ずつ作るのではなく、**SUGOSEKI と同じ Rails の MVC 構成で、UI・データ・業務ロジックを層ごとに切り分けて作る**。

---

## 1. 技術スタック（SUGOSEKI と揃える）

| 項目 | 採用 | SUGOSEKI との関係 |
|---|---|---|
| フレームワーク | Rails 8.1 | SUGOSEKI は 7.2。7.2 は 2026-08 にサポート終了のため、新規の本アプリは 8.1 で開始 |
| DB | MariaDB | 同じ |
| 画面 | ERB + Turbo + Stimulus（importmap / sprockets） | 同じ |
| 認証 | `has_secure_password`（Profile） | 同じ |
| 認可 | Pundit（Policy + Policy::Scope） | 同じ |
| 主キー | ULID（`UlidPk` concern） | 同じ（SUGOSEKI から移植） |
| 削除 | 論理削除のみ（`SoftDeletable` concern） | 同じ（SUGOSEKI から移植） |
| enum ラベル | enum_help + `config/locales/enums/ja.yml` | 同じ |
| デザイン | PGデザインコード v1.2 | 同じ |

---

## 2. レイヤー構成（どこに何を書くか）

```
app/
├── models/          データ層：テーブル1つ = モデル1つ。バリデーションと「そのデータ自身のルール」だけ
│   └── concerns/    共通部品（UlidPk / SoftDeletable / TenantOwned / ManYenAttribute / LandEnum）
├── policies/        認可層：「誰が・どのデータを・何をしてよいか」（Pundit）
├── finders/         検索層：一覧の絞り込み・並び替え（params → ActiveRecord::Relation）
├── services/        業務ロジック層：複数のモデルにまたがる処理（例：土地をまとめて紹介する）
├── controllers/     受付層：リクエストを受けて上の層を呼ぶだけ。ロジックは書かない
│   └── portal/      お客様専用ページ（スタッフ画面とは認証もレイアウトも別）
├── helpers/         表示整形（万円・坪・バッジ・アイコン）
├── views/           UI層：ERB
│   ├── layouts/     application（スタッフ）／ auth（ログイン）／ portal（お客様）
│   └── shared/      共通部品（土地カード・見出し・空状態・エラー表示など）
├── javascript/
│   └── controllers/ Stimulus（画面の小さな動き：㎡⇔坪の自動換算、URLコピー）
└── assets/stylesheets/
    ├── tokens.css      色・余白・角丸（デザイントークン。色はここ以外で直書きしない）
    ├── base.css        要素の素のスタイル
    ├── layout.css      スタッフ画面の骨組み
    ├── components.css  ボタン・カード・表・フォーム
    └── portal.css      お客様専用ページ（スマホ前提）
```

### 依存の向き

```
views ─→ helpers
  ↑
controllers ─→ policies（認可）
            ─→ finders（検索）
            ─→ services（業務処理）─→ models
```

- **Controller は薄く**：`authorize` → Finder / Service 呼び出し → render / redirect だけ。
- **Model は画面を知らない**：表示用の整形（「2,800万円」など）は helper に置く。
- **View はクエリを書かない**：必要なデータは Controller で用意して渡す。
- **CSS は役割ごとにファイルを分け**、色・寸法は `tokens.css` の変数だけを使う。

---

## 3. データモデル

```
companies（企業＝テナント）
 ├── profiles（スタッフ）
 ├── lands（土地）
 ├── customers（顧客）
 └── land_proposals（土地紹介 = 顧客 × 土地 ＋ お客様の反応）
```

| テーブル | 役割 | 主なカラム |
|---|---|---|
| companies | 企業（テナント） | name |
| profiles | ログインするスタッフ | company_id, name, email, password_digest, role(管理者/一般) |
| lands | 土地 | company_id, name, status, price, 住所, land_area(㎡), land_area_tsubo(坪), 建ぺい率, 容積率, zoning, land_category, topography, current_status, comment(お客様向け), remarks(社内のみ) |
| customers | 紹介先のお客様 | company_id, name, 連絡先, budget_max, desired_land_area_tsubo, desired_area |
| land_proposals | 紹介と反応 | company_id, customer_id, land_id, message, reaction(未確認/確認済み/気になる/見送り), viewed_at, reacted_at |

### 共通ルール
- 主キーは全テーブル ULID（26桁文字列）。
- 全業務テーブルに `company_id`。取得は必ず `policy_scope`（自社 × 未削除）経由。
- 削除は `soft_delete!`（`deleted_at`）。`destroy` は使わない。
- 金額は**円で保存**、画面は**万円で入出力**（`price_man_yen` などの仮想属性）。
- 面積は㎡を正とし、坪は自動計算（1㎡ = 0.3025坪）。
- `lands` のカラム名・enum の整数値は **pg-core `properties`（category=land）と同じ**にしてある。将来 SUGOSEKI / pg-core と連携・移行するときにそのまま対応付けられる。

---

## 4. 画面

### スタッフ向け（ログイン必須）
| URL | 画面 |
|---|---|
| `/login` | ログイン |
| `/`, `/lands` | 土地一覧（キーワード・ステータス・価格上限・面積下限・並び替え） |
| `/lands/:id` | 土地詳細（紹介したお客様と反応） |
| `/lands/new`, `/lands/:id/edit` | 土地の登録・編集（㎡⇔坪の自動換算） |
| `/customers` | 顧客一覧 |
| `/customers/:id` | 顧客詳細（紹介中の土地／専用ページURL／土地をまとめて紹介） |

### お客様向け（ログイン不要）
| URL | 画面 |
|---|---|
| `/p/:token` | ご紹介土地の一覧 |
| `/p/:token/proposals/:id` | 土地詳細＋「気になる／見送る」 |

- `:token` は `Customer#portal_token`（Rails の署名付きID）。顧客IDを直接晒さず、改ざん・総当たりもできない（SUGOSEKI の公開物件ページと同方式）。
- お客様に出すのは「紹介可・商談中」の土地だけ。成約・下書き・削除・紹介取消は自動で非表示。
- 社内備考（`remarks`）はお客様ページに一切出さない。

---

## 5. 今後の拡張候補（優先度順の案）

1. 土地の写真（Active Storage + S3）と地図表示
2. 顧客の希望条件（予算・面積・エリア）に合う土地の自動マッチング → 紹介候補の提示
3. お客様が「気になる」を押したら担当者へ通知（メール／Slack）
4. 土地情報の CSV 一括取込
5. SUGOSEKI（顧客・物件）との連携方式の決定（API 連携か、同一DBか）
