# frozen_string_literal:true

class Installation < ApplicationRecord
  belongs_to :company
  belongs_to :customer
  has_many :panels

  validates :date, :address1, :city, :country, presence: true
end
