# frozen_string_literal:true

class Company < ApplicationRecord
  has_many :installations

  validates :name, :siren, presence: true
  validates :siren, uniqueness: true
  validates :siren, numericality: { only_integer: true }
end
