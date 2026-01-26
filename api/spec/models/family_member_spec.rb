require 'rails_helper'

RSpec.describe FamilyMember, type: :model do
  describe 'バリデーション' do
    describe 'user_idのユニーク制約' do
      it '1ユーザーは1家族にしか所属できない' do
        user = create(:user)
        family1 = create(:family)
        family2 = create(:family)

        # 最初の家族に所属
        family_member1 = create(:family_member, user: user, family: family1)
        expect(family_member1).to be_valid

        # 別の家族に所属しようとするとエラーになる
        family_member2 = build(:family_member, user: user, family: family2)
        expect(family_member2).not_to be_valid
        expect(family_member2.errors[:user_id]).to include("は既に他の家族に所属しています")
      end

      it '異なるユーザーは同じ家族に所属できる' do
        family = create(:family)
        user1 = create(:user)
        user2 = create(:user)

        family_member1 = create(:family_member, user: user1, family: family)
        family_member2 = create(:family_member, user: user2, family: family)

        expect(family_member1).to be_valid
        expect(family_member2).to be_valid
      end
    end

    describe 'roleのデフォルト値' do
      it '新規作成時、roleが指定されていない場合はunspecifiedになる' do
        user = create(:user)
        family = create(:family)

        family_member = FamilyMember.new(user: user, family: family)
        family_member.save!

        expect(family_member.role).to eq('unspecified')
      end

      it 'roleが指定されている場合はその値が使用される' do
        user = create(:user)
        family = create(:family)

        family_member = create(:family_member, user: user, family: family, role: :mother)

        expect(family_member.role).to eq('mother')
      end
    end
  end

  describe 'アソシエーション' do
    it 'userとfamilyに正しく関連付けられる' do
      user = create(:user)
      family = create(:family)
      family_member = create(:family_member, user: user, family: family)

      expect(family_member.user).to eq(user)
      expect(family_member.family).to eq(family)
    end
  end
end

