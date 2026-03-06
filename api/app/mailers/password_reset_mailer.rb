class PasswordResetMailer < ApplicationMailer
  # パスワードリセット用メールを送信する
  # @param password_reset_token [PasswordResetToken] リセットトークン
  def reset_email(password_reset_token)
    @token = password_reset_token.token

    mail(
      to: password_reset_token.user.email,
      subject: "【FamilyOps】パスワード再設定のご案内",
      body: reset_email_body(@token)
    )
  end

  private

  def reset_email_body(token)
    url = password_reset_url(token:)

    <<~TEXT
      いつも Family Ops をご利用いただきありがとうございます。

      以下のリンクからパスワードを再設定してください。

      #{url}

      リンクの有効期限は1時間です。

      ※このメールに心当たりがない場合は、このメールを破棄してください。
    TEXT
  end

  def password_reset_url(token:)
    options = Rails.application.config.action_mailer.default_url_options || {}
    host = options[:host] || "localhost"
    protocol = options[:protocol] || "https"
    port = options[:port]

    port_part = port.present? ? ":#{port}" : ""

    "#{protocol}://#{host}#{port_part}/password-reset?token=#{token}"
  end
end

