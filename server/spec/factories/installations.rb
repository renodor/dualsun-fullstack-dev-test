# frozen_string_literal: true

FactoryBot.define do
  factory :installation do
    company
    customer

    date { Date.today }
    address { 'Address' }
    city { 'City' }
  end
end
