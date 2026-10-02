require "test_helper"

class LandProposalsRespondTest < ActiveSupport::TestCase
  setup { @proposal = land_proposals(:yamada_midori) }

  test "初回閲覧で確認済みになり、2回目以降は閲覧日時を変えない" do
    first = 1.hour.ago.change(usec: 0)
    LandProposals::Respond.new(@proposal).mark_viewed!(at: first)
    LandProposals::Respond.new(@proposal).mark_viewed!
    assert @proposal.reload.reaction_viewed?
    assert_equal first, @proposal.viewed_at
  end

  test "気になるを記録する" do
    LandProposals::Respond.new(@proposal).react!("interested")
    assert @proposal.reload.reaction_interested?
    assert @proposal.reacted_at.present?
  end

  test "想定外の反応は受け付けない" do
    assert_raises(ArgumentError) { LandProposals::Respond.new(@proposal).react!("unread") }
  end
end
