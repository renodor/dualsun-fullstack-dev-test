# frozen_string_literal:true

class Installation < ApplicationRecord
  belongs_to :company
  belongs_to :customer
  has_many :panels, dependent: :destroy

  validates :date, :address, :city, presence: true
end
