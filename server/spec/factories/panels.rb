# frozen_string_literal: true

FactoryBot.define do
  factory :panel do
    installation

    code { 123_456 }
    flavor { 'photovoltaic' }
  end
end
