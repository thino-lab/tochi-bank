# 土地の紹介（どのお客様に・どの土地を・誰が紹介したか）と、お客様の反応。
class CreateLandProposals < ActiveRecord::Migration[8.1]
  def change
    create_table :land_proposals, id: { type: :string, limit: 26 }, comment: "土地紹介" do |t|
      t.string :company_id, limit: 26, null: false, comment: "企業ID"
      t.string :customer_id, limit: 26, null: false, comment: "顧客ID"
      t.string :land_id, limit: 26, null: false, comment: "土地ID"
      t.string :proposed_by_id, limit: 26, comment: "紹介したスタッフ"
      t.text :message, comment: "お客様へのひとこと"
      t.integer :reaction, null: false, default: 0, comment: "お客様の反応（0:未確認 1:確認済み 2:気になる 3:見送り）"
      t.datetime :viewed_at, comment: "お客様が初めて閲覧した日時"
      t.datetime :reacted_at, comment: "お客様が反応した日時"
      t.datetime :deleted_at, comment: "論理削除日時"
      t.timestamps
    end
    add_index :land_proposals, [ :customer_id, :land_id ], unique: true
    add_index :land_proposals, [ :company_id, :created_at ]
    add_foreign_key :land_proposals, :companies
    add_foreign_key :land_proposals, :customers
    add_foreign_key :land_proposals, :lands
  end
end
