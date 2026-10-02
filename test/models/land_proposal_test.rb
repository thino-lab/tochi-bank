require "test_helper"

class LandProposalTest < ActiveSupport::TestCase
  test "同じお客様に同じ土地を二重に紹介できない" do
    dup = LandProposal.new(company: companies(:pure), customer: customers(:yamada), land: lands(:midori))
    assert_not dup.valid?
  end

  test "別企業の土地は紹介できない" do
    proposal = LandProposal.new(company: companies(:pure), customer: customers(:yamada), land: lands(:other_land))
    assert_not proposal.valid?
    assert_includes proposal.errors[:base], "別企業の顧客・土地は紐づけられません"
  end
end
