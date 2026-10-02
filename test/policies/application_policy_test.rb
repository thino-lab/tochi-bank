require "test_helper"

class ApplicationPolicyTest < ActiveSupport::TestCase
  test "Scope は自社の未削除レコードだけを返す" do
    lands(:sold).soft_delete!
    resolved = ApplicationPolicy::Scope.new(profiles(:admin), Land).resolve
    assert_equal [ lands(:midori), lands(:sakura) ].to_set, resolved.to_set
  end

  test "未ログインなら何も返さない" do
    assert_empty ApplicationPolicy::Scope.new(nil, Land).resolve
  end

  test "他社のレコードは参照・更新できない" do
    policy = LandPolicy.new(profiles(:admin), lands(:other_land))
    assert_not policy.show?
    assert_not policy.update?
  end

  test "土地の削除は管理者か担当者のみ" do
    assert LandPolicy.new(profiles(:admin), lands(:sakura)).destroy?
    assert LandPolicy.new(profiles(:member), lands(:sakura)).destroy?
    assert_not LandPolicy.new(profiles(:member), lands(:midori)).destroy?
  end
end
