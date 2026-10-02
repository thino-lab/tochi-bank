# 土地を紹介するお客様。pg-core の customers に相当。
class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers, id: { type: :string, limit: 26 }, comment: "顧客" do |t|
      t.string :company_id, limit: 26, null: false, comment: "企業ID"
      t.string :name, null: false, comment: "氏名"
      t.string :name_kana, comment: "氏名カナ"
      t.string :email, comment: "メールアドレス"
      t.string :tel, comment: "電話番号"
      t.bigint :budget_max, comment: "土地予算上限（円）"
      t.float :desired_land_area_tsubo, comment: "希望面積（坪）"
      t.text :desired_area, comment: "希望エリア"
      t.string :in_charge_user_id, limit: 26, comment: "担当者"
      t.datetime :deleted_at, comment: "論理削除日時"
      t.timestamps
    end
    add_index :customers, [ :company_id, :created_at ]
    add_foreign_key :customers, :companies
  end
end
