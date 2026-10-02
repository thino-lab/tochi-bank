require "test_helper"

class PortalFlowTest < ActionDispatch::IntegrationTest
  setup do
    @customer = customers(:yamada)
    @token = @customer.portal_token
    @proposal = land_proposals(:yamada_midori)
  end

  test "ログインなしで紹介土地の一覧を見られる" do
    get portal_root_path(@token)
    assert_response :success
    assert_select ".land-card__name", text: lands(:midori).name
  end

  test "社内備考はお客様に表示しない" do
    lands(:midori).update!(remarks: "値引き交渉余地あり（社外秘）")
    get portal_proposal_path(@token, @proposal)
    assert_response :success
    assert_no_match "社外秘", response.body
  end

  test "詳細を開くと確認済みになる" do
    get portal_proposal_path(@token, @proposal)
    assert @proposal.reload.reaction_viewed?
  end

  test "気になるを押すと反応が記録される" do
    patch react_portal_proposal_path(@token, @proposal, reaction: "interested")
    assert_redirected_to portal_proposal_path(@token, @proposal)
    assert @proposal.reload.reaction_interested?
  end

  test "成約・削除になった土地はお客様ページから消える" do
    lands(:midori).update!(status: :contracted)
    get portal_root_path(@token)
    assert_select ".land-card", count: 0
    get portal_proposal_path(@token, @proposal)
    assert_response :not_found
  end

  test "不正なトークンは404" do
    get portal_root_path("invalid-token")
    assert_response :not_found
  end

  test "他のお客様の紹介は開けない" do
    other = customers(:other_customer)
    get portal_proposal_path(other.portal_token, @proposal)
    assert_response :not_found
  end

  test "削除された顧客のページは開けない" do
    @customer.soft_delete!
    get portal_root_path(@token)
    assert_response :not_found
  end
end
