# pg-core 互換の enum コード定義。整数値は pg-core properties と完全一致させる。
# ラベルは config/locales/enums/ja.yml 参照。
module LandEnum
  ZONING = {
    first_low_rise_residential_zone: 0,
    second_low_rise_residential_zone: 1,
    first_high_rise_residential_zone: 2,
    second_high_rise_residential_zone: 3,
    first_residential_zone: 4,
    second_residential_zone: 5,
    countryside_residential_zone: 6,
    quasi_residential_zone: 7,
    neighborhood_commercial_zone: 8,
    commercial_zone: 9,
    quasi_industrial_zone: 10,
    industrial_zone: 11,
    exclusively_industrial_zone: 12,
    first_rise_residential_zone: 13, # pg-core の旧データ互換（「１種住居」）
    none: 99
  }.freeze

  LAND_CATEGORY = {
    field: 0, farmland: 1, residential_land: 2, school_land: 3, railway_land: 4, salt_field: 5,
    mineral_spring_land: 6, marsh: 7, forest: 8, pasture: 9, wilderness: 10, cemetery: 11,
    shrine: 12, canal_land: 13, water_supply_land: 14, drainage_land: 15, reservoir: 16,
    embankment: 17, ditch: 18, protected_forest: 19, public_road: 20, park: 21, mixed_use_land: 22
  }.freeze
end
