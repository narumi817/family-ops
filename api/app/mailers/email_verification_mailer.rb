class EmailVerificationMailer < ApplicationMailer
  # メールアドレス確認メールを送信する
  # @param verification [EmailVerification] 確認レコード
  def confirmation_email(verification)
    @verification = verification
    @token = verification.token

    mail(
      to: verification.email,
      subject: "【FamilyOps】メールアドレス確認のお願い"
    )
  end
end

