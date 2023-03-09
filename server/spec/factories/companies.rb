# frozen_string_literal: true

FactoryBot.define do
  factory :company do
    name { 'Company Name' }
    siren { 123_456_789 }
  end
end
