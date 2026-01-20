module Api
  module V1
    module Families
      class InvitationsController < ApplicationController
        before_action :require_login
        before_action :set_family

        # 家族への招待メールを送信する
        # POST /api/v1/families/:id/invitations
        # @param email [String] 招待先メールアドレス
        def create
          result = FamilyInvitationService.invite(
            family: @family,
            inviter: current_user,
            email: params[:email]
          )

          unless result[:success]
            payload = result[:errors] ? { errors: result[:errors] } : { error: result[:error] }
            return render json: payload, status: result[:status]
          end

          invitation = result[:invitation]
          FamilyInvitationMailer.invitation_email(invitation).deliver_now

          render json: {
            message: "招待メールを送信しました",
            invitation: {
              id: invitation.id,
              email: invitation.email,
              family_id: invitation.family_id
            }
          }, status: :created
        end

        private

        def set_family
          family_id = params[:family_id] || params[:id]
          @family = ::Family.find(family_id)
        end
      end
    end
  end
end


