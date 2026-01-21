module Api
  module V1
    class InvitationsController < ApplicationController
      # 招待トークンを検証する
      # GET /api/v1/invitations/verify
      # @param token [String] 招待トークン（必須）
      # @return [JSON] 検証結果（成功時は招待情報を返す）
      def verify
        token = params[:token].to_s

        if token.blank?
          return render json: { error: "トークンが指定されていません" }, status: :bad_request
        end

        invitation = FamilyInvitation.verify_token(token)
        unless invitation
          return render json: { error: "このリンクは無効か、有効期限が切れています" }, status: :bad_request
        end

        render json: {
          email: invitation.email,
          family: {
            id: invitation.family_id,
            name: invitation.family.name
          },
          inviter: {
            id: invitation.inviter.id,
            name: invitation.inviter.name
          },
          invited: true
        }, status: :ok
      end

      # 招待経由のサインアップ完了
      # POST /api/v1/invitations/complete
      # @param token [String] 招待トークン（必須）
      # @param name [String] ユーザー名（必須）
      # @param password [String] パスワード（必須）
      # @param password_confirmation [String] パスワード（確認用、必須）
      # @return [JSON] 作成されたユーザー・家族情報
      def complete
        result = InvitationSignupService.complete(
          token: params[:token],
          name: params[:name],
          password: params[:password],
          password_confirmation: params[:password_confirmation]
        )

        unless result[:success]
          payload = result[:errors] ? { errors: result[:errors] } : { error: result[:error] }
          return render json: payload, status: result[:status]
        end

        user = result[:user]
        family = result[:family]

        session[:user_id] = user.id

        render json: {
          user: {
            id: user.id,
            name: user.name,
            email: user.email
          },
          family: {
            id: family.id,
            name: family.name
          }
        }, status: :ok
      end
    end
  end
end


