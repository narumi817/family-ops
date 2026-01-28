require 'rails_helper'

RSpec.describe 'Api::V1::MasterData', type: :request do
  before do
    host! 'www.example.com'
  end

  describe 'GET /api/v1/master_data' do
    it 'rolesを含むマスタデータを返す' do
      get '/api/v1/master_data'

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json['roles']).to be_an(Array)

      # FamilyMemberのenumとvalueが一致していること
      enum_keys = FamilyMember.roles.keys
      returned_values = json['roles'].map { |r| r['value'] }

      expect(returned_values).to match_array(enum_keys)

      # ラベルが含まれていること
      json['roles'].each do |role|
        expect(role['label']).to be_present
      end
    end
  end
end
