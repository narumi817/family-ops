class RenameInvitedByToInviteUserIdInFamilyInvitations < ActiveRecord::Migration[8.0]
  def change
    rename_column :family_invitations, :invited_by, :invite_user_id
  end
end


