# frozen_string_literal: true

FactoryBot.define do
  factory :company do
    name { 'Company Name' }
    siren { 1234 }
  end
end
