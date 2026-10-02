# デモデータ（冪等：何度実行しても同じ状態になる）
company = Company.find_or_create_by!(name: "ピュアホーム株式会社")

admin = Profile.find_or_initialize_by(email: "tanaka@example.com")
admin.update!(company: company, name: "田中 太郎", role: :admin, password: "password")

member = Profile.find_or_initialize_by(email: "suzuki@example.com")
member.update!(company: company, name: "鈴木 花子", role: :member, password: "password")

lands = [
  { name: "緑ヶ丘3丁目 南向き整形地", price: 28_000_000, prefecture: "埼玉県", city: "さいたま市緑区", address_detail: "緑ヶ丘3丁目",
    land_area: 165.3, building_coverage_ratio: "60%", floor_area_ratio: "200%", zoning: :first_low_rise_residential_zone,
    land_category: :residential_land, topography: :flat, current_status: :vacant_land, adjacent_road: "南側 公道 6.0m",
    comment: "南道路で日当たり良好。小学校まで徒歩6分です。" },
  { name: "桜台 角地 建築条件なし", price: 35_800_000, prefecture: "埼玉県", city: "川口市", address_detail: "桜台1丁目",
    land_area: 198.0, building_coverage_ratio: "60%", floor_area_ratio: "150%", zoning: :first_residential_zone,
    land_category: :residential_land, topography: :flat, current_status: :has_old_house, adjacent_road: "東側 公道 5.0m／南側 公道 4.0m",
    comment: "2方向道路の角地。古家は売主負担で解体予定です。" },
  { name: "見沼 ひな壇 眺望良好", price: 19_800_000, prefecture: "埼玉県", city: "さいたま市見沼区", address_detail: "東宮下",
    land_area: 132.5, building_coverage_ratio: "50%", floor_area_ratio: "100%", zoning: :first_low_rise_residential_zone,
    land_category: :residential_land, topography: :tiered, current_status: :vacant_land, status: :in_negotiation }
]
lands.each do |attrs|
  Land.find_or_initialize_by(company: company, name: attrs[:name])
      .update!(attrs.reverse_merge(status: :available, in_charge_user: admin, created_by: admin))
end

customer = Customer.find_or_initialize_by(company: company, name: "山田 一郎")
customer.update!(name_kana: "ヤマダ イチロウ", email: "yamada@example.com", tel: "090-0000-0000",
                 budget_max: 30_000_000, desired_land_area_tsubo: 45, desired_area: "さいたま市緑区・見沼区", in_charge_user: admin)

LandProposals::Propose.new(
  customer: customer, lands: company.lands.proposable.limit(2), proposed_by: admin,
  message: "ご希望エリアに近い土地をご紹介します。"
).call

puts "seed 完了: ログイン tanaka@example.com / password"
puts "お客様ページ: /p/#{customer.portal_token}"
