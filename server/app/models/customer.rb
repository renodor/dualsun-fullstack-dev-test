# frozen_string_literal:true

class Customer < ApplicationRecord
  has_many :installations, dependent: :destroy

  validates :name, :email, :phone, presence: true
  validates :email, format: { with: /.+@.+\..+/ }
end
