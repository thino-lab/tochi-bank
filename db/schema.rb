# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_02_000005) do
  create_table "companies", id: { type: :string, limit: 26 }, charset: "utf8mb4", collation: "utf8mb4_general_ci", comment: "企業（テナント）", force: :cascade do |t|
    t.string "name", null: false, comment: "企業名"
    t.datetime "deleted_at", comment: "論理削除日時"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", id: { type: :string, limit: 26 }, charset: "utf8mb4", collation: "utf8mb4_general_ci", comment: "顧客", force: :cascade do |t|
    t.string "company_id", limit: 26, null: false, comment: "企業ID"
    t.string "name", null: false, comment: "氏名"
    t.string "name_kana", comment: "氏名カナ"
    t.string "email", comment: "メールアドレス"
    t.string "tel", comment: "電話番号"
    t.bigint "budget_max", comment: "土地予算上限（円）"
    t.float "desired_land_area_tsubo", comment: "希望面積（坪）"
    t.text "desired_area", comment: "希望エリア"
    t.string "in_charge_user_id", limit: 26, comment: "担当者"
    t.datetime "deleted_at", comment: "論理削除日時"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "created_at"], name: "index_customers_on_company_id_and_created_at"
  end

  create_table "land_proposals", id: { type: :string, limit: 26 }, charset: "utf8mb4", collation: "utf8mb4_general_ci", comment: "土地紹介", force: :cascade do |t|
    t.string "company_id", limit: 26, null: false, comment: "企業ID"
    t.string "customer_id", limit: 26, null: false, comment: "顧客ID"
    t.string "land_id", limit: 26, null: false, comment: "土地ID"
    t.string "proposed_by_id", limit: 26, comment: "紹介したスタッフ"
    t.text "message", comment: "お客様へのひとこと"
    t.integer "reaction", default: 0, null: false, comment: "お客様の反応（0:未確認 1:確認済み 2:気になる 3:見送り）"
    t.datetime "viewed_at", comment: "お客様が初めて閲覧した日時"
    t.datetime "reacted_at", comment: "お客様が反応した日時"
    t.datetime "deleted_at", comment: "論理削除日時"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "created_at"], name: "index_land_proposals_on_company_id_and_created_at"
    t.index ["customer_id", "land_id"], name: "index_land_proposals_on_customer_id_and_land_id", unique: true
    t.index ["land_id"], name: "fk_rails_8ba948ed93"
  end

  create_table "lands", id: { type: :string, limit: 26 }, charset: "utf8mb4", collation: "utf8mb4_general_ci", comment: "土地", force: :cascade do |t|
    t.string "company_id", limit: 26, null: false, comment: "企業ID"
    t.string "name", null: false, comment: "土地名（社内呼称）"
    t.integer "status", default: 0, null: false, comment: "ステータス（0:紹介可 1:商談中 2:成約 3:下書き）"
    t.bigint "price", comment: "価格（円）"
    t.string "postal_code", comment: "郵便番号"
    t.string "prefecture", comment: "都道府県"
    t.string "city", comment: "市区町村"
    t.string "address_detail", comment: "住所詳細"
    t.decimal "latitude", precision: 9, scale: 7, comment: "緯度"
    t.decimal "longitude", precision: 10, scale: 7, comment: "経度"
    t.float "land_area", comment: "土地面積（㎡）"
    t.float "land_area_tsubo", comment: "土地面積（坪）"
    t.string "building_coverage_ratio", comment: "建ぺい率"
    t.string "floor_area_ratio", comment: "容積率"
    t.integer "zoning", comment: "用途地域"
    t.integer "land_category", comment: "地目"
    t.integer "topography", comment: "地勢"
    t.integer "current_status", comment: "現況"
    t.boolean "has_building_conditions", default: false, null: false, comment: "建築条件の有無"
    t.text "adjacent_road", comment: "道路（方位・幅員）"
    t.text "comment", comment: "お客様向けコメント"
    t.text "remarks", comment: "社内備考（お客様には表示しない）"
    t.string "in_charge_user_id", limit: 26, comment: "担当者"
    t.string "created_by_id", limit: 26, comment: "登録者"
    t.datetime "deleted_at", comment: "論理削除日時"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "status", "created_at"], name: "index_lands_on_company_id_and_status_and_created_at"
  end

  create_table "profiles", id: { type: :string, limit: 26 }, charset: "utf8mb4", collation: "utf8mb4_general_ci", comment: "スタッフ", force: :cascade do |t|
    t.string "company_id", limit: 26, null: false, comment: "企業ID"
    t.string "name", null: false, comment: "氏名"
    t.string "email", null: false, comment: "メールアドレス（ログインID）"
    t.string "password_digest", null: false
    t.integer "role", default: 1, null: false, comment: "権限（0:管理者 1:一般）"
    t.datetime "deleted_at", comment: "論理削除日時"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_profiles_on_company_id"
    t.index ["email"], name: "index_profiles_on_email", unique: true
  end

  add_foreign_key "customers", "companies"
  add_foreign_key "land_proposals", "companies"
  add_foreign_key "land_proposals", "customers"
  add_foreign_key "land_proposals", "lands"
  add_foreign_key "lands", "companies"
  add_foreign_key "profiles", "companies"
end
