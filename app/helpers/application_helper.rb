module ApplicationHelper
  # 細線の SVG アイコン（Lucide 系）。絵文字をアイコン代わりに使わない（PGデザインコード）。
  ICONS = {
    map:    '<path d="M9 3 3 5v16l6-2 6 2 6-2V3l-6 2-6-2z"/><path d="M9 3v16M15 5v16"/>',
    users:  '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/>',
    plus:   '<path d="M12 5v14M5 12h14"/>',
    search: '<circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/>',
    back:   '<path d="m15 18-6-6 6-6"/>',
    link:   '<path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/>',
    heart:  '<path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"/>',
    x:      '<path d="M18 6 6 18M6 6l12 12"/>'
  }.freeze

  def icon(name, css: "icon")
    tag.svg(ICONS.fetch(name).html_safe, class: css, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor",
            "stroke-width": 1.75, "stroke-linecap": "round", "stroke-linejoin": "round", "aria-hidden": true)
  end

  # 金額は「万円」表記（1億以上は「億」も使う）
  def man_yen(yen)
    return "—" if yen.blank?
    man = yen / 10_000.0
    if man >= 10_000
      oku, rest = man.divmod(10_000)
      rest.zero? ? "#{oku.to_i}億円" : "#{oku.to_i}億#{number_with_delimiter(rest.round)}万円"
    else
      "#{number_with_delimiter(man % 1 == 0 ? man.to_i : man.round(1))}万円"
    end
  end

  def tsubo(value)
    value.blank? ? "—" : "#{number_with_precision(value, precision: 2, strip_insignificant_zeros: true)}坪"
  end

  def sqm(value)
    value.blank? ? "—" : "#{number_with_precision(value, precision: 2, strip_insignificant_zeros: true)}㎡"
  end

  def nav_link(label, path, icon_name, active:)
    link_to path, class: ("is-active" if active) do
      safe_join([ icon(icon_name), label ])
    end
  end
end
