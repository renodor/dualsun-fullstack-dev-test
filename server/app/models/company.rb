# frozen_string_literal:true

class Company < ApplicationRecord
  has_many :installations, dependent: :destroy

  validates :name, :siren, presence: true
  validates :siren, uniqueness: true
  validates :siren, numericality: { only_integer: true }
  validates :siren, format: { with: /\d{4}/ }
end
