# スタッフ（ログインユーザー）。pg-core の users に相当（SUGOSEKI と同じく profiles と命名）。
class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles, id: { type: :string, limit: 26 }, comment: "スタッフ" do |t|
      t.string :company_id, limit: 26, null: false, comment: "企業ID"
      t.string :name, null: false, comment: "氏名"
      t.string :email, null: false, comment: "メールアドレス（ログインID）"
      t.string :password_digest, null: false
      t.integer :role, null: false, default: 1, comment: "権限（0:管理者 1:一般）"
      t.datetime :deleted_at, comment: "論理削除日時"
      t.timestamps
    end
    add_index :profiles, :email, unique: true
    add_index :profiles, :company_id
    add_foreign_key :profiles, :companies
  end
end
