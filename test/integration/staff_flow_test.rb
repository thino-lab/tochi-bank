require "test_helper"

class StaffFlowTest < ActionDispatch::IntegrationTest
  test "未ログインはログイン画面へ" do
    get lands_path
    assert_redirected_to login_path
  end

  test "誤ったパスワードではログインできない" do
    sign_in profiles(:admin), password: "wrong"
    assert_response :unprocessable_entity
  end

  test "土地一覧には自社の土地だけが出る" do
    sign_in profiles(:admin)
    get lands_path
    assert_response :success
    assert_select ".land-card__name", text: lands(:midori).name
    assert_select ".land-card__name", text: lands(:other_land).name, count: 0
  end

  test "他社の土地の詳細は見られない" do
    sign_in profiles(:admin)
    get land_path(lands(:other_land))
    assert_response :not_found
  end

  test "土地を万円・㎡で登録できる" do
    sign_in profiles(:admin)
    assert_difference -> { Land.count } do
      post lands_path, params: { land: { name: "新規土地", status: "available", price_man_yen: "2480", land_area: "120" } }
    end
    land = Land.order(:created_at).last
    assert_equal 24_800_000, land.price
    assert_in_delta 36.3, land.land_area_tsubo
    assert_equal companies(:pure).id, land.company_id
    assert_redirected_to land_path(land)
  end

  test "削除は論理削除" do
    sign_in profiles(:admin)
    assert_no_difference -> { Land.count } do
      delete land_path(lands(:midori))
    end
    assert lands(:midori).reload.deleted?
  end

  test "顧客に土地を紹介できる（他社・成約済みの土地は混ぜられない）" do
    sign_in profiles(:admin)
    customer = customers(:yamada)
    assert_difference -> { customer.land_proposals.count }, 1 do
      post customer_land_proposals_path(customer),
           params: { land_ids: [ lands(:sakura).id, lands(:sold).id, lands(:other_land).id ], message: "どうぞ" }
    end
    assert_redirected_to customer_path(customer)
    assert_equal [ lands(:midori), lands(:sakura) ].to_set, customer.land_proposals.map(&:land).to_set
  end

  test "顧客詳細にお客様専用ページのURLが出る" do
    sign_in profiles(:admin)
    get customer_path(customers(:yamada))
    assert_response :success
    assert_select "input[value=?]", portal_root_url(customers(:yamada).portal_token)
  end
end
