require "resend"

# Resend API クライアントの初期化
Resend.api_key = ENV["RESEND_API_KEY"]

class ResendDeliveryMethod
  def initialize(_options = {})
  end

  # ActionMailer から呼ばれるエントリポイント
  def deliver!(mail)
    unless Resend.api_key.present?
      Rails.logger.error "[Resend] RESEND_API_KEY が設定されていません。メールは送信されません。"
      return
    end

    from_email = ENV["RESEND_FROM_EMAIL"]
    unless from_email.present?
      Rails.logger.error "[Resend] RESEND_FROM_EMAIL が設定されていません。メールは送信されません。"
      return
    end

    params = {
      from: from_email,
      to: Array(mail.to),
      subject: mail.subject
    }

    if mail.html_part
      params[:html] = mail.html_part.body.to_s
      params[:text] = mail.text_part&.body&.to_s
    else
      # textテンプレートのみの場合
      params[:text] = mail.body.to_s
    end

    Resend::Emails.send(params)
  rescue StandardError => e
    Rails.logger.error "[Resend] メール送信中にエラーが発生しました: #{e.class} - #{e.message}"
  end
end

# delivery_method :resend を使えるように登録
ActionMailer::Base.add_delivery_method :resend, ResendDeliveryMethod


