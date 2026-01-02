class AddOauthToUsers < ActiveRecord::Migration[8.0]
  def change
    # OAuth認証用のカラムを追加
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    
    # password_digestをnullableにする（外部認証の場合は不要）
    change_column_null :users, :password_digest, true
    
    # emailをnullableにする（外部認証でも取得できるが、必須ではない場合もある）
    change_column_null :users, :email, true
    
    # providerとuidの組み合わせでユニーク制約（同じプロバイダーで同じIDは1つだけ）
    # 部分インデックス: providerがNULLでない場合のみユニーク制約を適用
    add_index :users, [:provider, :uid], unique: true, where: "provider IS NOT NULL"
    
    # 注意: パスワード認証と外部認証のどちらかは必須
    # これはDB制約ではなく、アプリケーションレベルでバリデーションする必要があります
  end
end
