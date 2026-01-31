module Api
  module V1
    module Family
      class PointsController < ApplicationController
        before_action :require_login

        # ログイン中のユーザーの当日の累計ポイントを取得する
        # GET /api/v1/family/points/today
        # @return [JSON] 当日の累計ポイント情報
        def today
          user = current_user
          family = user.family

          unless family
            render json: { error: "家族が見つかりません" }, status: :not_found
            return
          end

          today = Date.current
          today_points = ::Log.today_points_for_user(user.id, family.id, date: today)

          render json: {
            user_id: user.id,
            user_name: user.name,
            today_points: today_points,
            date: today.to_s
          }, status: :ok
        end
      end
    end
  end
end

