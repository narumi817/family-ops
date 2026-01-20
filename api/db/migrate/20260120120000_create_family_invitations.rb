class CreateFamilyInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :family_invitations do |t|
      t.references :family, null: false, foreign_key: { on_delete: :cascade }
      t.string :email, null: false
      t.string :token, null: false
      t.datetime :token_expired_at, null: false
      t.bigint :invited_by, null: false
      t.datetime :accepted_at

      t.timestamps
    end

    add_index :family_invitations, :token, unique: true
    add_index :family_invitations, :email
    add_foreign_key :family_invitations, :users, column: :invited_by, on_delete: :cascade
  end
end


