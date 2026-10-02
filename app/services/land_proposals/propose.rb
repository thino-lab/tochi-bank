# お客様に土地をまとめて紹介する。
# 既に紹介済みの土地はスキップし（削除済みなら復活）、新規分だけ作成する＝何度実行しても安全。
module LandProposals
  class Propose
    Result = Struct.new(:created, :skipped, keyword_init: true)

    def initialize(customer:, lands:, proposed_by:, message: nil)
      @customer = customer
      @lands = lands
      @proposed_by = proposed_by
      @message = message
    end

    def call
      created = []
      skipped = []
      LandProposal.transaction do
        @lands.each do |land|
          proposal = LandProposal.find_or_initialize_by(customer: @customer, land: land)
          if proposal.persisted? && !proposal.deleted?
            skipped << proposal
            next
          end
          proposal.assign_attributes(
            company_id: @customer.company_id, proposed_by: @proposed_by, message: @message,
            reaction: :unread, viewed_at: nil, reacted_at: nil, deleted_at: nil
          )
          proposal.save!
          created << proposal
        end
      end
      Result.new(created: created, skipped: skipped)
    end
  end
end
