# ULID(26桁 Crockford Base32)を主キーに採番する concern。
# pg-core は 26桁文字列ULIDをPKに採用しているためそれを踏襲（gem不要の自前実装）。
module UlidPk
  extend ActiveSupport::Concern

  ENCODING = "0123456789ABCDEFGHJKMNPQRSTVWXYZ".freeze # Crockford Base32

  included do
    before_create :assign_ulid
  end

  private

  def assign_ulid
    self.id = self.class.generate_ulid if id.blank?
  end

  class_methods do
    # 48bitミリ秒タイムスタンプ(10文字) + 80bitランダム(16文字) = 26文字
    def generate_ulid
      time_ms = (Time.now.utc.to_f * 1000).to_i
      randomness = SecureRandom.random_number(2**80)
      encode(time_ms, 10) + encode(randomness, 16)
    end

    def encode(int, length)
      str = +""
      length.times do
        str.prepend(UlidPk::ENCODING[int % 32])
        int /= 32
      end
      str
    end
  end
end
