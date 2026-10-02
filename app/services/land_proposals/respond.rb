# お客様専用ページからの反応（閲覧・気になる・見送り）を記録する。
module LandProposals
  class Respond
    REACTIONS = %w[interested declined].freeze

    def initialize(proposal)
      @proposal = proposal
    end

    # 初回閲覧を記録（未確認 → 確認済み）
    def mark_viewed!(at: Time.current)
      return if @proposal.viewed_at.present?
      attrs = { viewed_at: at }
      attrs[:reaction] = :viewed if @proposal.reaction_unread?
      @proposal.update!(attrs)
    end

    def react!(reaction, at: Time.current)
      raise ArgumentError, "不正な反応です: #{reaction}" unless REACTIONS.include?(reaction.to_s)
      @proposal.update!(reaction: reaction, reacted_at: at, viewed_at: @proposal.viewed_at || at)
    end
  end
end
