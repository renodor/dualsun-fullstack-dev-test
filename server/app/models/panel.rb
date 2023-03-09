# frozen_string_literal:true

class Panel < ApplicationRecord
  belongs_to :installation

  validates :code, :flavor, presence: true
  validates :code, uniqueness: true
  validates :code, numericality: { only_integer: true }

  enum flavor: {
    photovoltaic: 0,
    hybrid: 1
  }
end
