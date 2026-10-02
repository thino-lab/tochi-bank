class Company < ApplicationRecord
  include UlidPk
  include SoftDeletable

  has_many :profiles
  has_many :lands
  has_many :customers
  has_many :land_proposals

  validates :name, presence: true
end
