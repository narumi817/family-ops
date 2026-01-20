class FamilyInvitationMailer < ApplicationMailer
  # 家族招待メールを送信する
  # @param invitation [FamilyInvitation] 招待レコード
  def invitation_email(invitation)
    @invitation = invitation
    @token = invitation.token
    @family_name = invitation.family.name
    @inviter_name = invitation.inviter.name

    mail(
      to: invitation.email,
      subject: "【FamilyOps】家族への招待"
    )
  end
end


