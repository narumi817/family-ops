class RenameTokenExpiresAtToTokenExpiredAtInEmailVerifications < ActiveRecord::Migration[8.0]
  def change
    rename_column :email_verifications, :token_expires_at, :token_expired_at
  end
end
