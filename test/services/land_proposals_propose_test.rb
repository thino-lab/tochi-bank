require "test_helper"

class LandProposalsProposeTest < ActiveSupport::TestCase
  test "新規分だけ紹介し、紹介済みはスキップする" do
    result = LandProposals::Propose.new(
      customer: customers(:yamada), lands: [ lands(:midori), lands(:sakura) ], proposed_by: profiles(:admin), message: "ぜひ"
    ).call

    assert_equal [ lands(:sakura) ], result.created.map(&:land)
    assert_equal [ lands(:midori) ], result.skipped.map(&:land)
    assert_equal "ぜひ", result.created.first.message
    assert_equal companies(:pure).id, result.created.first.company_id
  end

  test "取り消した紹介は再紹介すると未確認に戻って復活する" do
    proposal = land_proposals(:yamada_midori)
    proposal.update!(reaction: :declined)
    proposal.soft_delete!

    result = LandProposals::Propose.new(customer: customers(:yamada), lands: [ lands(:midori) ], proposed_by: profiles(:admin)).call

    assert_equal [ proposal.id ], result.created.map(&:id)
    assert proposal.reload.reaction_unread?
    assert_not proposal.deleted?
  end
end
