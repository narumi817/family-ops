class CreateEmailVerifications < ActiveRecord::Migration[8.0]
  def change
    create_table :email_verifications do |t|
      t.references :user, null: true, foreign_key: { on_delete: :cascade }
      t.string :email, null: false
      t.string :token, null: false
      t.datetime :token_expires_at, null: false
      t.datetime :verified_at

      t.timestamps
    end
    add_index :email_verifications, :token, unique: true
    add_index :email_verifications, :email
    # user_idのインデックスはt.referencesで自動的に作成されるため不要
  end
end
