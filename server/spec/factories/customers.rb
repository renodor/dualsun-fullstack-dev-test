# frozen_string_literal: true

FactoryBot.define do
  factory :customer do
    name { 'Customer Name' }
    email { 'customer@email.com' }
    phone { '+33612345678' }
  end
end
