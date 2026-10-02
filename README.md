# tochi-bank
土地バンク／顧客向け土地紹介アプリ

住宅会社のスタッフが土地を登録し、お客様ごとに土地を紹介。お客様は専用ページ（ログイン不要）で紹介された土地を見て「気になる／見送る」を回答できる。

- 構成：Rails 8.1 / MariaDB / Turbo + Stimulus（SUGOSEKI と同じ MVC 構成。アプリ・DBは独立）
- 設計方針：[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- 開発ルール：[CLAUDE.md](CLAUDE.md)

## セットアップ

```bash
bundle install
bin/rails db:prepare db:seed
bin/rails server   # http://localhost:3000/login（tanaka@example.com / password）
```

## テスト

```bash
bin/rails test
bin/rubocop
bin/brakeman
```
