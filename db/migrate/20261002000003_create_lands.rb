# 土地バンクの土地。カラム名は pg-core properties（category=land）と揃え、将来の連携・移行を容易にする。
class CreateLands < ActiveRecord::Migration[8.1]
  def change
    create_table :lands, id: { type: :string, limit: 26 }, comment: "土地" do |t|
      t.string :company_id, limit: 26, null: false, comment: "企業ID"
      t.string :name, null: false, comment: "土地名（社内呼称）"
      t.integer :status, null: false, default: 0, comment: "ステータス（0:紹介可 1:商談中 2:成約 3:下書き）"
      t.bigint :price, comment: "価格（円）"
      t.string :postal_code, comment: "郵便番号"
      t.string :prefecture, comment: "都道府県"
      t.string :city, comment: "市区町村"
      t.string :address_detail, comment: "住所詳細"
      t.decimal :latitude, precision: 9, scale: 7, comment: "緯度"
      t.decimal :longitude, precision: 10, scale: 7, comment: "経度"
      t.float :land_area, comment: "土地面積（㎡）"
      t.float :land_area_tsubo, comment: "土地面積（坪）"
      t.string :building_coverage_ratio, comment: "建ぺい率"
      t.string :floor_area_ratio, comment: "容積率"
      t.integer :zoning, comment: "用途地域"
      t.integer :land_category, comment: "地目"
      t.integer :topography, comment: "地勢"
      t.integer :current_status, comment: "現況"
      t.boolean :has_building_conditions, null: false, default: false, comment: "建築条件の有無"
      t.text :adjacent_road, comment: "道路（方位・幅員）"
      t.text :comment, comment: "お客様向けコメント"
      t.text :remarks, comment: "社内備考（お客様には表示しない）"
      t.string :in_charge_user_id, limit: 26, comment: "担当者"
      t.string :created_by_id, limit: 26, comment: "登録者"
      t.datetime :deleted_at, comment: "論理削除日時"
      t.timestamps
    end
    add_index :lands, [ :company_id, :status, :created_at ]
    add_foreign_key :lands, :companies
  end
end
