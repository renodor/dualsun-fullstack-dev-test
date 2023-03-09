# frozen_string_literal: true

FactoryBot.define do
  factory :installation do
    company
    customer

    date { Date.today }
    address1 { 'Address 1' }
    city { 'City' }
    country { 'Country' }
  end
end
