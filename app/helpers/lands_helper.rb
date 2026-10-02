module LandsHelper
  STATUS_BADGES = { "available" => "badge--accent", "in_negotiation" => "badge--warn", "contracted" => "badge--navy" }.freeze
  REACTION_BADGES = { "interested" => "badge--accent", "declined" => "badge--warn", "viewed" => "" }.freeze

  def land_status_badge(land)
    tag.span(land.status_i18n, class: [ "badge", STATUS_BADGES[land.status] ])
  end

  def reaction_badge(proposal)
    tag.span(proposal.reaction_i18n, class: [ "badge", REACTION_BADGES[proposal.reaction] ])
  end
end
