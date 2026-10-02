# 企業（テナント）。pg-core の enterprises に相当（SUGOSEKI と同じく companies と命名）。
class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies, id: { type: :string, limit: 26 }, comment: "企業（テナント）" do |t|
      t.string :name, null: false, comment: "企業名"
      t.datetime :deleted_at, comment: "論理削除日時"
      t.timestamps
    end
  end
end
