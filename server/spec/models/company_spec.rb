# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company, type: :model do
  context 'associations' do
    it { is_expected.to have_many(:installations) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:siren) }
    it { is_expected.to validate_numericality_of(:siren).only_integer }
  end
end