# tochi-bank（土地バンク）— Claude Code 作業指針

住宅会社向けの地図型 土地探し・営業支援ツール（「土地BANK」の自社版、マルチテナント）。
何を作るかは [docs/PRODUCT_PLAN.md](docs/PRODUCT_PLAN.md)。
Rails 8.1 / MariaDB / MVC 構成。設計方針の詳細は [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)。
構成・規約は SUGOSEKI（`yhosoyama-prog/sugoseki`）に揃えているが、**アプリとしては独立**している
（DB・アカウント・デプロイ先は土地バンク専用。SUGOSEKI の DB には接続しない）。

---

## 1. 開発サーバ起動

```bash
docker compose up -d   # MariaDB（127.0.0.1:3310）
bin/setup              # gem・DB作成・マイグレーション・デモデータ・サーバ起動（何度実行しても安全）
# → http://localhost:3000/login
```

- ログイン: `tanaka@example.com` / `password`（管理者）
- お客様ページの URL は `db:seed` の最後に表示される（顧客詳細画面からもコピーできる）
- DB 接続は環境変数で上書きできる：`DB_HOST` / `DB_PORT` / `DB_USERNAME` / `DB_PASSWORD` / `DB_SOCKET`（既定は docker-compose の DB）
- 詳しい手順（Mac / Windows）は README.md

---

## 2. どこに何を書くか（層を混ぜない）

| 層 | 置き場所 | 書くこと |
|---|---|---|
| データ | `app/models` | バリデーション・関連・そのデータ自身のルール（坪換算など） |
| 認可 | `app/policies` | 誰が何をしてよいか（Pundit） |
| 検索 | `app/finders` | 一覧の絞り込み・並び替え |
| 業務ロジック | `app/services` | 複数モデルにまたがる処理（紹介する・反応を記録する） |
| 受付 | `app/controllers` | authorize → finder/service 呼び出し → render。ロジックは書かない |
| 表示整形 | `app/helpers` | 万円・坪・バッジ・アイコン |
| UI | `app/views` | ERB。共通部品は `views/shared/` |
| 動き | `app/javascript/controllers` | Stimulus |
| 見た目 | `app/assets/stylesheets` | 色・寸法は `tokens.css` の変数だけを使う |

---

## 3. DB ルール

- **主キー**: ULID（`UlidPk` concern）
- **削除**: 論理削除のみ（`SoftDeletable`、`soft_delete!`）。`destroy` / `delete` / `destroy_all` は使わない
- **マルチテナント**: 全業務テーブルに `company_id`。Controller では必ず `policy_scope` 経由で取得する
- **金額**: DB は円、画面は万円（`man_yen_attribute`）
- lands のカラム名・enum 整数値は pg-core `properties` を参考にしている。新しいカラムを足すときは、同じ意味のカラムが pg-core にあれば名前を合わせる（推奨。独立アプリなので必須ではない）
- テーブル・カラムを追加するときは作業前に報告して確認を取る：

```
⚠️ DB変更あり
- 追加するテーブル/カラム: [名前]
- pg-core に同じ意味の項目: [あり（名前）/なし]
- 追加理由: [理由]
このまま進めてもよいですか？
```

- DB 変更後は `db/schema.rb` もコミットする

---

## 4. お客様専用ページ（`app/controllers/portal/`）

- ログイン不要。アクセスは `Customer#portal_token`（署名付き）のみ
- スタッフ画面とは基底クラス・レイアウトを分けている（`Portal::BaseController` / `layouts/portal`）
- お客様に見せるデータは `visible_proposals` 経由に限定する（紹介可・商談中の土地だけ）
- **社内備考（`remarks`）などの社内情報をお客様向けビューに出さない**

---

## 5. コーディング規約

- 日本語でコメント・UIラベルを書く（識別子は英語）
- 変更時は影響範囲を明示し、テスト項目をチェックボックスで提示する
- 秘密情報をコミットしない（`config/master.key` / `.env` は gitignore 済み）

---

## 6. テスト・静的チェック

```bash
bin/rails test        # 全テスト
bin/rubocop           # Lint
bin/brakeman          # セキュリティ
```

CI（`.github/workflows/ci.yml`）で上記と importmap audit を実行する。

---

## 7. やってはいけないこと

- `destroy` / `delete` で物理削除する
- `company_id` スコープを外してテナント横断クエリを書く
- Pundit の Policy を通さずにデータを返す
- Controller / View に検索条件や業務ロジックを書く（Finder / Service に置く）
- CSS に色コードを直書きする（`tokens.css` の変数を使う）

---

## 8. デザインコード（PGデザインコード v1.2）

1. **色**：白 × 濃紺 `#123770`。アクセントはターコイズ `#00b6c9`（効かせる場所だけ）。オレンジ `#fa7748` は注意・警告のみ。紫・金・ピンク系を基調色にしない
2. **言葉**：UIは日本語。フォントは Noto Sans JP
3. **ロゴ**：加工しない
4. **禁止**：絵文字アイコン／全面ダーク背景／グラデーション文字・グロー・グラスモーフィズム

- ヘッダー・ヒーローは濃紺、コンテンツは白
- 角丸は 4〜8px、影は薄く
- アイコンは細線 SVG（`icon` helper、Lucide 系）
- 動きをひとつ入れる（カードのホバー、フラッシュのふわっと表示など）
