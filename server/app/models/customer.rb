# frozen_string_literal:true

class Customer < ApplicationRecord
  has_many :installations

  validates :name, :email, :phone, presence: true
  # TODO: validate email and phone format?
end
