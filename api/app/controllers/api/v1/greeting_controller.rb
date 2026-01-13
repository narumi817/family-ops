module Api
  module V1
    class GreetingController < ApplicationController
      before_action :require_login

      # ログイン済みユーザーに労いのメッセージをランダムに返す
      # GET /api/v1/greeting
      # @return [JSON] ランダムなメッセージ
      def show
        message = random_greeting_message
        render json: {
          message: message,
          user_name: current_user.name
        }, status: :ok
      end

      private

      # ランダムな労いメッセージを返す
      # @return [String] メッセージ
      def random_greeting_message
        GreetingMessages.sample
      end
    end
  end
end

