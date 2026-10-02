# tochi-bank
土地バンク／顧客向け土地紹介アプリ

住宅会社のスタッフが土地を登録し、お客様ごとに土地を紹介。お客様は専用ページ（ログイン不要）で紹介された土地を見て「気になる／見送る」を回答できる。

- 構成：Rails 8.1 / MariaDB / Turbo + Stimulus（SUGOSEKI と同じ MVC 構成。アプリ・DBは独立）
- 設計方針：[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- 開発ルール：[CLAUDE.md](CLAUDE.md)

## 環境

| 環境 | 用途 | 状態 |
|---|---|---|
| ローカル | 各自の PC で開発・動作確認 | ✅ 下の手順で起動できる |
| ステージング | 本番と同じ構成での検証・社内確認 | 準備中 |
| 本番 | お客様・スタッフが使う | 未構築 |

## ローカル環境のセットアップ

### 必要なもの（最初に1回）

| ツール | Mac | Windows |
|---|---|---|
| Git | `xcode-select --install` | WSL2（Ubuntu）を入れ、以降は WSL のターミナルで作業 |
| Docker | Docker Desktop | Docker Desktop（WSL2 連携を ON） |
| Ruby 3.3.6 | `brew install rbenv ruby-build` → `rbenv install`（`.ruby-version` を読む） | WSL 内で rbenv を入れて `rbenv install` |
| MariaDB クライアント | `brew install mariadb-connector-c` | `sudo apt install libmariadb-dev` |

DB（MariaDB）は Docker で動かすので、PC に MariaDB サーバを入れる必要はありません。

### 起動

```bash
git clone git@github.com:thino-lab/tochi-bank.git
cd tochi-bank
docker compose up -d   # DB を起動（127.0.0.1:3310。SUGOSEKI の DB とはぶつからない）
bin/setup              # gem 取得 → DB 作成 → デモデータ → サーバ起動
```

- スタッフ画面: http://localhost:3000/login（`tanaka@example.com` / `password`）
- お客様ページ: `bin/setup` の途中に表示される `/p/...` の URL（顧客詳細画面からもコピーできる）
- 2回目以降は `docker compose up -d` → `bin/rails server` だけで OK
- `config/master.key` はローカル開発には不要です

### よく使うコマンド

```bash
docker compose down          # DB を停止（データは残る）
docker compose down -v       # DB を停止してデータも消す（作り直したいとき）
bin/rails db:seed            # デモデータを入れ直す（何度実行しても同じ状態になる）
bin/rails db:migrate         # マイグレーションを適用
```

### 自前の MariaDB を使う場合

Docker を使わず手元の MariaDB に接続するときは、環境変数で上書きします。

```bash
DB_PORT=3306 DB_PASSWORD= bin/setup
```

| 変数 | 既定値 |
|---|---|
| `DB_HOST` | `127.0.0.1` |
| `DB_PORT` | `3310` |
| `DB_USERNAME` | `root` |
| `DB_PASSWORD` | `tochi` |
| `DB_SOCKET` | なし |

## テスト

```bash
bin/rails test
bin/rubocop
bin/brakeman
```
