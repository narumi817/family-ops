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
    end
  end
end


