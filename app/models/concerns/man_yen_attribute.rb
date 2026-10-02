# 円で保存するカラムを、フォームでは「万円」で入出力するための仮想属性を生やす。
#   man_yen_attribute :price  # => price_man_yen / price_man_yen=
module ManYenAttribute
  extend ActiveSupport::Concern

  class_methods do
    def man_yen_attribute(column)
      define_method(:"#{column}_man_yen") do
        yen = public_send(column)
        return nil if yen.nil?
        man = yen / 10_000.0
        man == man.to_i ? man.to_i : man
      end

      define_method(:"#{column}_man_yen=") do |value|
        public_send(:"#{column}=", value.blank? ? nil : (BigDecimal(value.to_s.delete(",")) * 10_000).to_i)
      end
    end
  end
end
