require "test_helper"

class LandTest < ActiveSupport::TestCase
  test "主キーは26桁のULIDで採番される" do
    land = companies(:pure).lands.create!(name: "新しい土地")
    assert_match(/\A[0-9A-HJKMNP-TV-Z]{26}\z/, land.id)
  end

  test "㎡を入力すると坪が自動計算される" do
    land = companies(:pure).lands.create!(name: "面積テスト", land_area: 100)
    assert_in_delta 30.25, land.land_area_tsubo
  end

  test "価格は万円で入力でき、円で保存される" do
    land = Land.new(price_man_yen: "2,980")
    assert_equal 29_800_000, land.price
    assert_equal 2980, land.price_man_yen
  end

  test "坪単価を計算する" do
    assert_equal 560_000, lands(:midori).price_per_tsubo
  end

  test "紹介できるのは未削除の紹介可・商談中の土地だけ" do
    lands(:sakura).soft_delete!
    assert_equal [ lands(:midori), lands(:other_land) ].sort_by(&:id), Land.proposable.order(:id).to_a
  end

  test "論理削除しても行は残る" do
    land = lands(:midori)
    land.soft_delete!
    assert land.reload.deleted?
    assert_not_includes Land.active, land
  end

  test "enum の日本語ラベルを返す" do
    assert_equal "第一種低層住居専用地域", lands(:midori).zoning_i18n
    assert_equal "紹介可", lands(:midori).status_i18n
  end

  test "他社のスタッフを担当者にできない" do
    land = lands(:midori)
    land.in_charge_user = profiles(:other_admin)
    assert_not land.valid?
    assert land.errors.added?(:in_charge_user, "は同じ企業のものを選択してください")
  end
end
