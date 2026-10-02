require "test_helper"

class LandsFinderTest < ActiveSupport::TestCase
  setup { @scope = Land.active.where(company: companies(:pure)) }

  def find(params) = LandsFinder.new(@scope, params).call.to_a

  test "価格上限（万円）で絞り込む" do
    assert_equal [ lands(:sold), lands(:midori) ].to_set, find(price_max: "3000").to_set
  end

  test "面積下限（坪）で絞り込む" do
    assert_equal [ lands(:sakura), lands(:midori) ].to_set, find(tsubo_min: "45").to_set
  end

  test "キーワードで住所を検索する" do
    assert_equal [ lands(:sakura) ], find(q: "川口")
  end

  test "ステータスで絞り込み、不正な値は無視する" do
    assert_equal [ lands(:sakura) ], find(status: "in_negotiation")
    assert_equal 3, find(status: "bogus").size
  end

  test "価格の安い順に並べる" do
    assert_equal [ lands(:sold), lands(:midori), lands(:sakura) ], find(sort: "price_asc")
  end
end
