module Api
  module V1
    class MasterDataController < ApplicationController
      # 各種マスタデータを返す
      # GET /api/v1/master_data
      def show
        render json: {
          roles: family_roles
        }, status: :ok
      end

      private

      def family_roles
        # FamilyMemberのenumを単一のソースにして、ここからラベル付きの配列を生成する
        FamilyMember.roles.keys.map do |key|
          {
            value: key,
            label: role_label_for(key)
          }
        end
      end

      def role_label_for(key)
        case key.to_s
        when 'unspecified' then '指定なし'
        when 'mother'      then '母'
        when 'father'      then '父'
        when 'child'       then '子'
        when 'other'       then 'その他'
        else key.to_s
        end
      end
    end
  end
end
